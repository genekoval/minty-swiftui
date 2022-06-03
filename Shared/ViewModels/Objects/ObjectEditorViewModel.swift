import Combine
import Foundation
import Minty

enum EditorState {
    case adding
    case moving
    case movingInsertionPoint
    case selecting
}

class Selectable: ObservableObject {
    let object: ObjectPreview
    private let action: (UUID) async throws -> Void

    @Published var selected = false

    init(object: ObjectPreview, action: @escaping (UUID) async throws -> Void) {
        self.object = object
        self.action = action
    }

    func performAction() async throws {
        try await action(object.id)
    }
}

enum EditorItem: Identifiable {
    case object(Selectable)
    case addButton(([ObjectPreview]) async throws -> Void, () -> Void)
    case placeholder(() async throws -> Void)

    var id: String {
        switch self {
        case .object(let selectable):
            return selectable.object.id.uuidString
        case .addButton(_, _):
            return "button.add"
        case .placeholder(_):
            return "placeholder"
        }
    }
}

protocol ObjectCollection {
    var objects: [ObjectPreview] { get set }

    var objectsPublisher: Published<[ObjectPreview]>.Publisher { get }
}

protocol ObjectEditorSubscriber {
    func add(objects: [UUID], at position: Int) async throws

    func delete(objects: [UUID]) async throws

    func move(objects: [UUID], to destination: UUID?) async throws
}

class ObjectEditorViewModel: ObservableObject {
    @Published var insertionPoint: Int = Int.max
    @Published var items: [EditorItem] = [] {
        didSet {
            cancellables.removeAll()

            selectables.publisher
                .flatMap { $0.objectWillChange }
                .sink(receiveValue: self.objectWillChange.send)
                .store(in: &cancellables)
        }
    }
    @Published var state: EditorState = .adding

    private var addButton: EditorItem!
    private var cancellables = Set<AnyCancellable>()
    private var collection: ObjectCollection
    private var objectsCancellable: AnyCancellable?
    private var stateCancellable: AnyCancellable?
    private var subscriber: ObjectEditorSubscriber?

    var allSelected: Bool {
        selected.count == collection.objects.count
    }

    var isEmpty: Bool {
        collection.objects.isEmpty
    }

    private var selectables: [Selectable] {
        items
            .compactMap {
                switch $0 {
                case .object(let selectable):
                    return selectable
                default:
                    return nil
                }
            }
    }

    var selected: [ObjectPreview] {
        selectables.compactMap { $0.selected ? $0.object : nil }
    }

    init(
        collection: ObjectCollection,
        subscriber: ObjectEditorSubscriber? = nil
    ) {
        self.collection = collection
        self.subscriber = subscriber

        addButton = .addButton(addObjects, {
            self.state = .movingInsertionPoint
        })

        objectsCancellable = collection.objectsPublisher.sink { [weak self] in
            self?.rebuildItems(objects: $0)
        }

        stateCancellable = $state.dropFirst().sink { [weak self] in
            self?.stateChanged(to: $0)
        }

        enableAddButton()
    }

    private func addObjects(_ objects: [ObjectPreview]) async throws {
        try await subscriber?.add(
            objects: objects.map { $0.id },
            at: insertionPoint
        )
        collection.objects.insert(contentsOf: objects, at: insertionPoint)

        insertionPoint += collection.objects.count
        enableAddButton()
    }

    private func deleteObjects(_ objects: [ObjectPreview]) async throws {
        try await subscriber?.delete(objects: objects.map { $0.id })

        collection.objects.remove(all: objects)

        if isEmpty {
            state = .adding
        }
    }

    func deleteSelected() async throws {
        try await deleteObjects(selected)
    }

    func deselectAll() {
        setSelection(false)
    }

    private func disableAddButton() {
        items.remove(at: insertionPoint)
    }

    private func enableAddButton() {
        insertionPoint = min(insertionPoint, items.count)
        items.insert(addButton, at: insertionPoint)
    }

    private func moveInsertionPoint(to destination: Int) {
        disableAddButton()
        insertionPoint = destination
        enableAddButton()

        state = .adding
    }

    private func moveObjects(
        _ objects: [ObjectPreview],
        to destination: UUID?
    ) async throws {
        try await subscriber?.move(
            objects: objects.map { $0.id },
            to: destination
        )

        let source = IndexSet(objects.compactMap { object in
            collection.objects.firstIndex(of: object)
        })

        let offset = destination == nil ?
            collection.objects.count :
            collection.objects.firstIndex(where: { $0.id == destination })!

        collection.objects.move(fromOffsets: source, toOffset: offset)

        state = .adding
    }

    private func moveSelected(to destination: UUID? = nil) async throws {
        try await moveObjects(selected, to: destination)
    }

    private func moveSelectedToEnd() async throws {
        try await moveSelected()
    }

    private func rebuildItems(objects: [ObjectPreview]) {
        items.removeAll(keepingCapacity: true)

        items.append(contentsOf: objects.map {
            .object(Selectable(object: $0, action: selectableAction))
        })
    }

    private func selectableAction(id: UUID) async throws {
        if state == .moving {
            try await moveSelected(to: id)
        }
        else if state == .movingInsertionPoint {
            let index = items.firstIndex(where: { $0.id == id.uuidString })!
            moveInsertionPoint(to: index)
        }
    }

    func selectAll() {
        setSelection(true)
    }

    private func stateChanged(to state: EditorState) {
        let previous = self.state

        if
            (previous == .moving || previous == .movingInsertionPoint) &&
            items.last?.id == "placeholder"
        {
            items.removeLast()
        }

        if state == .adding && previous != .movingInsertionPoint {
            deselectAll()
            enableAddButton()
        }
        else if state == .moving {
            items.append(.placeholder(moveSelectedToEnd))
        }
        else if state == .selecting && previous == .adding {
            disableAddButton()
        }
    }

    private func setSelection(_ value: Bool) {
        for item in items {
            if case .object(let selectable) = item {
                selectable.selected = value
            }
        }
    }
}

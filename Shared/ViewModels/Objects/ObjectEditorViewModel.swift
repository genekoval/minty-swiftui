import Combine
import Foundation
import Minty

enum EditorState {
    case adding
    case moving
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
    case placeholder(() async throws -> Void)

    var id: String {
        switch self {
        case .object(let selectable):
            return selectable.object.id.uuidString
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
    func add(objects: [UUID], before destination: UUID?) async throws

    func delete(objects: [UUID]) async throws

    func move(objects: [UUID], to destination: UUID?) async throws
}

class ObjectEditorViewModel: ObservableObject {
    @Published var items: [EditorItem] = [] {
        didSet {
            cancellables.removeAll()

            selectables.publisher
                .flatMap { $0.objectWillChange }
                .sink(receiveValue: self.objectWillChange.send)
                .store(in: &cancellables)
        }
    }
    @Published var showingUploadView = false
    @Published var state: EditorState = .adding

    private var cancellables = Set<AnyCancellable>()
    private var collection: ObjectCollection
    private var insertionPoint: UUID?
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

        objectsCancellable = collection.objectsPublisher.sink { [weak self] in
            self?.rebuildItems(objects: $0)
        }

        stateCancellable = $state.dropFirst().sink { [weak self] in
            self?.stateChanged(to: $0)
        }
    }

    func addObjects(_ objects: [ObjectPreview]) async throws {
        try await subscriber?.add(
            objects: objects.map { $0.id },
            before: insertionPoint
        )

        if let insertionPoint = insertionPoint {
            collection.objects.insert(
                contentsOf: objects,
                at: collection.objects.firstIndex(
                    where: { $0.id == insertionPoint }
                )!
            )
        }
        else {
            collection.objects.append(contentsOf: objects)
        }
    }

    private func appendObjects() async throws {
        insertionPoint = nil
        showingUploadView = true
    }

    private func deleteObjects(_ objects: [ObjectPreview]) async throws {
        try await subscriber?.delete(objects: objects.map { $0.id })

        collection.objects.remove(all: objects)

        state = .adding
    }

    func deleteSelected() async throws {
        try await deleteObjects(selected)
    }

    func deselectAll() {
        setSelection(false)
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
        if state == .adding {
            insertionPoint = id
            showingUploadView = true
        }
        else if state == .moving {
            try await moveSelected(to: id)
        }
    }

    func selectAll() {
        setSelection(true)
    }

    private func stateChanged(to state: EditorState) {
        let previous = self.state

        if previous == .adding || previous == .moving {
            items.removeLast()
        }
        else if previous == .selecting {
            deselectAll()
        }

        if state == .adding {
            items.append(.placeholder(appendObjects))
        }
        else if state == .moving {
            items.append(.placeholder(moveSelectedToEnd))
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

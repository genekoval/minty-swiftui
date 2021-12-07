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
    private let action: (String) -> Void

    @Published var selected = false

    init(object: ObjectPreview, action: @escaping (String) -> Void) {
        self.object = object
        self.action = action
    }

    func performAction() {
        action(object.id)
    }
}

enum EditorItem: Identifiable {
    case object(Selectable)
    case addButton(([String]) -> Void, () -> Void)
    case placeholder(() -> Void)

    var id: String {
        switch self {
        case .object(let selectable):
            return selectable.object.id
        case .addButton(_, _):
            return "button.add"
        case .placeholder(_):
            return "placeholder"
        }
    }
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
    private var objectsCancellable: AnyCancellable?
    private let post: PostViewModel
    private var stateCancellable: AnyCancellable?

    var allSelected: Bool {
        selected.count == post.objects.count
    }

    var isEmpty: Bool {
        post.objects.isEmpty
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

    var selected: [String] {
        selectables.compactMap { $0.selected ? $0.object.id : nil }
    }

    init(post: PostViewModel) {
        self.post = post
        addButton = .addButton(addObjects, {
            self.state = .movingInsertionPoint
        })

        stateCancellable = $state.dropFirst().sink { [weak self] in
            self?.stateChanged(to: $0)
        }

        objectsCancellable = post.$objects.sink { [weak self] in
            self?.rebuildItems(objects: $0)
        }

        enableAddButton()
    }

    private func addObjects(objects: [String]) {
        post.addObjects(objects, at: insertionPoint)
        insertionPoint += objects.count
        enableAddButton()
    }

    func deleteSelected() {
        post.delete(objects: selected)

        if isEmpty {
            state = .adding
        }
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

    private func moveSelected(to destination: String? = nil) {
        post.moveObjects(objects: selected, destination: destination)
        state = .adding
    }

    private func moveSelectedToEnd() {
        moveSelected()
    }

    private func rebuildItems(objects: [ObjectPreview]) {
        items.removeAll(keepingCapacity: true)

        items.append(contentsOf: objects.map {
            .object(Selectable(object: $0, action: selectableAction))
        })
    }

    private func selectableAction(id: String) {
        if state == .moving {
            moveSelected(to: id)
        }
        else if state == .movingInsertionPoint {
            let index = items.firstIndex(where: { $0.id == id })!
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

import Combine
import Minty

class Selectable: ObservableObject {
    let object: ObjectPreview

    @Published var selected = false

    init(object: ObjectPreview) {
        self.object = object
    }
}

enum EditorItem: Identifiable {
    case object(Selectable)
    case addButton(([String]) -> Void)

    var id: String {
        switch self {
        case .object(let selectable):
            return selectable.object.id
        case .addButton(_):
            return "button.add"
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
    @Published var isSelecting = false

    private var addButton: EditorItem!
    private var cancellables = Set<AnyCancellable>()
    private var isSelectingCancellable: AnyCancellable?
    private var objectsCancellable: AnyCancellable?
    private let post: PostViewModel

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
        items.compactMap {
            switch $0 {
            case .object(let selectable):
                return selectable.selected ? selectable.object.id : nil
            default:
                return nil
            }
        }
    }

    init(post: PostViewModel) {
        self.post = post
        addButton = .addButton(addObjects)

        isSelectingCancellable = $isSelecting
            .dropFirst()
            .sink { [weak self] in self?.selectionModeChanged(to: $0) }

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
            isSelecting = false
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

    private func rebuildItems(objects: [ObjectPreview]) {
        items.removeAll(keepingCapacity: true)

        items.append(contentsOf: objects.map {
            .object(Selectable(object: $0))
        })
    }

    func selectAll() {
        setSelection(true)
    }

    private func selectionModeChanged(to selecting: Bool) {
        if selecting {
            disableAddButton()
        }
        else {
            deselectAll()
            enableAddButton()
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

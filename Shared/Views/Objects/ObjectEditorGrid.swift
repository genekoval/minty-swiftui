import Combine
import Minty
import SwiftUI

private let moveSymbol = "arrow.up.and.down.and.arrow.left.and.right"

private enum EditorState {
    case adding
    case moving
    case selecting
}

private class SelectableObject: Identifiable, ObservableObject {
    @Published var selected = false

    let object: ObjectPreview
    unowned let editor: Editor

    var id: ObjectPreview.ID {
        object.id
    }

    init(object: ObjectPreview, editor: Editor) {
        self.object = object
        self.editor = editor
    }

    @MainActor
    func add() {
        editor.add(to: object)
    }

    func moveHere() async throws {
        try await editor.move(to: object)
    }
}

@MainActor
private class Editor: ObservableObject {
    @Published var state: EditorState = .adding
    @Published var showingUploadView = false

    @Published private(set) var objects: [SelectableObject] = [] {
        didSet {
            cancellables.removeAll()

            objects
                .publisher
                .flatMap { $0.objectWillChange }
                .sink(receiveValue: objectWillChange.send)
                .store(in: &cancellables)
        }
    }

    private var cancellables = Set<AnyCancellable>()
    private var destination: ObjectPreview?
    private let post: PostViewModel
    private var postCancellable: AnyCancellable?

    var allSelected: Bool {
        selected.count == objects.count
    }

    var noneSelected: Bool {
        selected.isEmpty
    }

    var selected: [SelectableObject] {
        objects.filter { $0.selected }
    }

    var selectedObjects: [ObjectPreview] {
        selected.map { $0.object }
    }

    init(post: PostViewModel) {
        self.post = post

        postCancellable = post.$objects.sink { [weak self] objects in
            guard let self else { return }

            self.objects = objects.map {
                SelectableObject(object: $0, editor: self)
            }
        }
    }

    func add(objects: [ObjectPreview]) async throws {
        if let destination {
            try await post.insert(objects: objects, before: destination)
        }
        else {
            try await post.add(objects: objects)
        }
    }

    func add(to destination: ObjectPreview? = nil) {
        self.destination = destination
        showingUploadView = true
    }

    func delete() async throws {
        try await post.delete(objects: selectedObjects)
    }

    func deselectAll() {
        setSelection(false)
    }

    func move(to destination: ObjectPreview? = nil) async throws {
        if let destination {
            try await post.insert(objects: selectedObjects, before: destination)
        }
        else {
            try await post.add(objects: selectedObjects)
        }

        state = .adding
    }

    func selectAll() {
        setSelection(true)
    }

    private func setSelection(_ selected: Bool) {
        for object in objects {
            object.selected = selected
        }
    }

    func toggleSelection() {
        allSelected ? deselectAll() : selectAll()
    }
}

private struct ObjectView: View {
    @EnvironmentObject private var errorHandler: ErrorHandler

    @ObservedObject var selectable: SelectableObject
    @ObservedObject var editor: Editor

    var body: some View {
        PreviewImage(object: selectable.object)
            .opacity(moving ? 0.5 : 1.0)
            .onTapGesture {
                switch editor.state {
                case .adding:
                    selectable.add()
                case .moving:
                    if !selectable.selected {
                        errorHandler.handle {
                            try await selectable.moveHere()
                        }
                    }
                case .selecting:
                    selectable.selected.toggle()
                }
            }
            .onLongPressGesture {
                if editor.state == .adding {
                    editor.state = .selecting
                    selectable.selected.toggle()
                }
            }
            .overlay {
                if editor.state == .selecting {
                    SelectionIndicator(isSelected: selectable.selected)
                        .font(.title2)
                }
                else if moving {
                    Image(systemName: moveSymbol)
                        .font(.title2)
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 1, x: 0, y: 1)
                }
            }
    }

    private var moving: Bool {
        editor.state == .moving && selectable.selected
    }
}

struct ObjectEditorGrid: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var errorHandler: ErrorHandler

    @StateObject private var editor: Editor

    var body: some View {
        ScrollView {
            VStack {
                Grid {
                    ForEach(editor.objects) {
                        ObjectView(selectable: $0, editor: editor)
                    }

                    if state == .adding || (state == .moving && !movingLast) {
                        Button(action: state == .adding ? add : move) {
                            GridPlaceholder()
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if state != .adding {
                        Button(action: {
                            editor.state = .adding
                            editor.deselectAll()
                        }) {
                            Text("Done")
                                .bold()
                        }
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    if state == .selecting {
                        Button(
                            "\(editor.allSelected ? "Deselect" : "Select") All"
                        ) {
                            editor.toggleSelection()
                        }
                    }
                    else if state == .moving {
                        Button("Cancel") {
                            editor.state = .selecting
                        }
                    }
                }

                ToolbarItem(placement: .bottomBar) {
                    Button(action: { editor.state = .moving }) {
                        Image(systemName: moveSymbol)
                    }
                    .disabled(editor.allSelected || editor.noneSelected)
                }

                ToolbarItem(placement: .bottomBar) {
                    Button(action: delete) {
                        Image(systemName: "trash")
                    }
                    .disabled(editor.noneSelected)
                }
            }
        }
        .toolbar(editor.state == .adding ? .visible : .hidden, for: .tabBar)
        .toolbar(
            editor.state == .selecting ? .visible : .hidden,
             for: .bottomBar
        )
        .navigationBarBackButtonHidden(editor.state != .adding)
        .postControlsHdden(editor.state != .adding)
        .objectUploadView(isPresented: $editor.showingUploadView) {
            try await editor.add(objects: $0)
        }
    }

    private var movingLast: Bool {
        let selected = editor.selected

        if let last = selected.last {
            return selected.count == 1 && last.id == editor.objects.last!.id
        }

        return false
    }

    private var state: EditorState {
        editor.state
    }

    private var title: String {
        if state == .adding {
            return "Add Objects"
        }

        let count = editor.selected.count

        if state == .moving {
            return "Move \(count) Object\(count == 1 ? "" : "s")"
        }

        return count == 0 ?
            "Select Objects" : "\(count) Object\(count == 1 ? "" : "s")"
    }

    init(post: PostViewModel) {
        _editor = StateObject(wrappedValue: Editor(post: post))
    }

    private func add() {
        editor.add()
    }

    private func delete() {
        errorHandler.handle {
            try await editor.delete()
        }
    }

    private func move() {
        errorHandler.handle {
            try await editor.move()
        }
    }
}

import SwiftUI

private let moveSymbol = "arrow.up.and.down.and.arrow.left.and.right"

private struct AddButton: View {
    let onUpload: ([String]) -> Void
    let alternateAction: () -> Void

    let state: EditorState

    @State private var showingUploadView = false

    var body: some View {
        Button(action: { }) {
            Image(systemName: "doc.fill.badge.plus")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .opacity(state == .movingInsertionPoint ? 0.5 : 1.0)
                .frame(width: 50)
                .overlay {
                    if state == .movingInsertionPoint {
                        Image(systemName: moveSymbol)
                            .font(.title2)
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 1, x: 0, y: 1)
                    }
                }
        }
        .simultaneousGesture(TapGesture().onEnded {
            if state == .adding { showingUploadView = true }
        })
        .simultaneousGesture(LongPressGesture().onEnded { _ in
            alternateAction()
        })
        .sheet(isPresented: $showingUploadView) {
            NavigationView {
                ObjectUploadView(onUpload: onUpload)
            }
        }
    }
}

private struct SelectorItem: View {
    @ObservedObject var selectable: Selectable

    let state: EditorState

    var body: some View {
        PreviewImage(object: selectable.object)
            .opacity(isMoving ? 0.5 : 1.0)
            .onTapGesture {
                if state == .selecting {
                    selectable.selected.toggle()
                }
                else if isMoveTarget {
                    selectable.performAction()
                }
            }
            .overlay {
                if state == .selecting {
                    SelectionIndicator(isSelected: selectable.selected)
                        .font(.title2)
                }
                else if isMoving {
                    Image(systemName: moveSymbol)
                        .font(.title2)
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 1, x: 0, y: 1)
                }
            }
    }

    private var isMoving: Bool {
        state == .moving && selectable.selected
    }

    private var isMoveTarget: Bool {
        (state == .moving && !selectable.selected) ||
        state == .movingInsertionPoint
    }
}

private struct Placeholder: View {
    let action: () -> Void

    var body: some View {
        Image(systemName: "square.dashed")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.secondary)
            .frame(width: 50)
            .onTapGesture { action() }
    }
}

private struct EditorItemView: View {
    let item: EditorItem

    let state: EditorState

    var body: some View {
        switch item {
        case .object(let selectable):
            SelectorItem(selectable: selectable, state: state)
        case .addButton(let didUpload, let alternateAction):
            AddButton(
                onUpload: didUpload,
                alternateAction: alternateAction,
                state: state
            )
        case .placeholder(let action):
            Placeholder(action: action)
        }
    }
}

struct ObjectEditorGrid: View {
    @StateObject private var editor: ObjectEditorViewModel

    var body: some View {
        ScrollView {
            VStack {
                itemGrid
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(editor.state != .adding)
        .toolbar {
            ToolbarItem(placement: .primaryAction) { selectButton }
            ToolbarItem(placement: .cancellationAction) { selectAllButton }
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Spacer()
                    moveButton
                    Spacer()
                    deleteButton
                    Spacer()
                }
            }
        }
    }

    @ViewBuilder
    private var deleteButton: some View {
        if editor.state == .selecting {
            Button(action: { editor.deleteSelected() }) {
                Image(systemName: "trash")
            }
            .disabled(editor.selected.isEmpty)
        }
    }

    @ViewBuilder
    private var itemGrid: some View {
        Grid {
            ForEach(editor.items) {
                EditorItemView(item: $0, state: editor.state)
            }
        }
        .animation(Animation.easeOut(duration: 0.25), value: editor.state)
    }

    @ViewBuilder
    private var moveButton: some View {
        if editor.state == .selecting {
            Button(action: { editor.state = .moving }) {
                Image(systemName: moveSymbol)
            }
            .disabled(editor.selected.isEmpty || editor.allSelected)
        }
    }

    @ViewBuilder
    private var selectButton: some View {
        if editor.state == .selecting || !editor.isEmpty {
            Button(action: {
                switch (editor.state) {
                case .adding:
                    editor.state = .selecting
                case .moving:
                    editor.state = .selecting
                case .movingInsertionPoint:
                    editor.state = .adding
                case .selecting:
                    editor.state = .adding
                }
            }) {
                if editor.state == .adding {
                    Text("Select")
                }
                else {
                    Text("Done")
                        .bold()
                }
            }
        }
    }

    @ViewBuilder
    private var selectAllButton: some View {
        if editor.state == .selecting && !editor.isEmpty {
            Button("\(editor.allSelected ? "Deselect" : "Select") All") {
                editor.allSelected ? editor.deselectAll() : editor.selectAll()
            }
        }
    }

    private var title: String {
        switch (editor.state) {
        case .adding:
            return "Objects"
        case .moving:
            let selected = editor.selected.count
            var text = "Move \(selected) Object"
            if selected != 1 {
                text += "s"
            }
            return text
        case .movingInsertionPoint:
            return "Move Insertion Point"
        case .selecting:
            let selected = editor.selected.count
            if selected == 0 { return "Select Objects" }

            let suffix = selected == 1 ? "Object" : "Objects"
            return "\(selected) \(suffix)"
        }
    }

    init(post: PostViewModel) {
        _editor = StateObject(wrappedValue: ObjectEditorViewModel(post: post))
    }
}

struct ObjectEditorGrid_Previews: PreviewProvider {
    private static let deleted = Deleted()
    @State private static var post = PostViewModel.preview(
        id: "test",
        deleted: deleted
    )

    static var previews: some View {
        NavigationView {
            ObjectEditorGrid(post: post)
        }
        .environmentObject(ObjectSource.preview)
    }
}
import SwiftUI

private struct SelectorItem: View {
    @ObservedObject var selectable: Selectable

    let isSelecting: Bool

    var body: some View {
        PreviewImage(object: selectable.object)
            .onTapGesture {
                if isSelecting {
                    selectable.selected.toggle()
                }
            }
            .overlay {
                if isSelecting {
                    SelectionIndicator(isSelected: selectable.selected)
                        .font(.title2)
                }
            }
    }
}

private struct EditorItemView: View {
    let item: EditorItem
    let isSelecting: Bool

    var body: some View {
        switch item {
        case .object(let selectable):
            SelectorItem(selectable: selectable, isSelecting: isSelecting)
        case .addButton(let didUpload):
            ObjectUploadButton(onUpload: didUpload)
                .frame(width: 50)
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
        .navigationBarBackButtonHidden(editor.isSelecting)
        .toolbar {
            ToolbarItem(placement: .primaryAction) { selectButton }
            ToolbarItem(placement: .cancellationAction) { selectAllButton }
            ToolbarItem(placement: .bottomBar) { deleteButton }
        }
    }

    @ViewBuilder
    private var deleteButton: some View {
        if editor.isSelecting {
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
                EditorItemView(item: $0, isSelecting: editor.isSelecting)
            }
        }
        .animation(Animation.easeOut(duration: 0.25), value: editor.isSelecting)
    }

    @ViewBuilder
    private var selectButton: some View {
        if editor.isSelecting || !editor.isEmpty {
            Button(action: { editor.isSelecting.toggle() }) {
                if editor.isSelecting {
                    Text("Done")
                        .bold()
                }
                else {
                    Text("Select")
                }
            }
        }
    }

    @ViewBuilder
    private var selectAllButton: some View {
        if editor.isSelecting && !editor.isEmpty {
            Button("\(editor.allSelected ? "Deselect" : "Select") All") {
                editor.allSelected ? editor.deselectAll() : editor.selectAll()
            }
        }
    }

    private var title: String {
        if !editor.isSelecting { return "Objects" }

        let selected = editor.selected.count
        if selected == 0 { return "Select Objects" }

        let suffix = selected == 1 ? "Object" : "Objects"
        return "\(selected) \(suffix)"
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

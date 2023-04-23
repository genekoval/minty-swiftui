import Minty
import SwiftUI

private let moveSymbol = "arrow.up.and.down.and.arrow.left.and.right"

private struct SelectorItem: View {
    @EnvironmentObject var errorHandler: ErrorHandler

    @ObservedObject var selectable: Selectable

    let state: EditorState

    var body: some View {
        PreviewImage(object: selectable.object)
            .opacity(isMoving ? 0.5 : 1.0)
            .simultaneousGesture(TapGesture().onEnded {
                switch state {
                case .adding:
                    errorHandler.handle {
                        try await selectable.performAction()
                    }
                case .moving:
                    if !selectable.selected {
                        errorHandler.handle {
                            try await selectable.performAction()
                        }
                    }
                case .selecting:
                    selectable.selected.toggle()
                }
            })
            .simultaneousGesture(LongPressGesture().onEnded { _ in
                if state == .adding {
                    // TODO: Context Menu
                }
            })
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
}

private struct Placeholder: View {
    @EnvironmentObject var errorHandler: ErrorHandler

    let action: () async throws -> Void

    var body: some View {
        Image(systemName: "square.dashed")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.secondary)
            .frame(width: 50)
            .onTapGesture {
                errorHandler.handle { try await action() }
            }
    }
}

private struct EditorItemView: View {
    @Binding var showingUploadView: Bool

    let item: EditorItem

    let state: EditorState

    var body: some View {
        switch item {
        case .object(let selectable):
            SelectorItem(
                selectable: selectable,
                state: state
            )
        case .placeholder(let action):
            Placeholder(action: action)
        }
    }
}

struct ObjectEditorGrid: View {
    @EnvironmentObject var errorHandler: ErrorHandler

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
                    if editor.state == .selecting {
                        Spacer()
                        moveButton
                        Spacer()
                        deleteButton
                        Spacer()
                    }
                }
            }
        }
        .sheet(isPresented: $editor.showingUploadView) {
            NavigationView {
                ObjectUploadView(onUpload: editor.addObjects)
            }
        }
    }

    @ViewBuilder
    private var deleteButton: some View {
        Button(action: {
            errorHandler.handle {
                try await editor.deleteSelected()
            }
        }) {
            Image(systemName: "trash")
        }
        .disabled(editor.selected.isEmpty)
    }

    @ViewBuilder
    private var itemGrid: some View {
        Grid {
            ForEach(editor.items) {
                EditorItemView(
                    showingUploadView: $editor.showingUploadView,
                    item: $0,
                    state: editor.state
                )
            }
        }
        .animation(Animation.easeOut(duration: 0.25), value: editor.state)
    }

    @ViewBuilder
    private var moveButton: some View {
        Button(action: { editor.state = .moving }) {
            Image(systemName: moveSymbol)
        }
        .disabled(editor.selected.isEmpty || editor.allSelected)
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
            let text = "Move \(selected) Object\(selected == 1 ? "" : "s")"
            return text
        case .selecting:
            let selected = editor.selected.count
            if selected == 0 { return "Select Objects" }
            return "\(selected) Object\(selected == 1 ? "" : "s")"
        }
    }

    init(
        collection: ObjectCollection,
        subscriber: ObjectEditorSubscriber? = nil
    ) {
        _editor = StateObject( wrappedValue: ObjectEditorViewModel(
            collection: collection,
            subscriber: subscriber
        ))
    }
}

struct ObjectEditorGrid_Previews: PreviewProvider {
    @State private static var post = PostViewModel.preview(id: PreviewPost.test)

    static var previews: some View {
        NavigationView {
            ObjectEditorGrid(collection: post)
        }
        .environmentObject(ObjectSource.preview)
    }
}

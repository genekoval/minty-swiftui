import SwiftUI

private struct TagSelectRow: View {
    @EnvironmentObject private var errorHandler: ErrorHandler

    let tag: TagViewModel
    let post: PostViewModel

    var body: some View {
        SelectableRow(
            onSelected: onSelected,
            onDeselected: onDeselected
        ) {
            TagRow(tag: tag)
        }
    }

    private func onDeselected() {
        errorHandler.handle {
            try await post.delete(tag: tag)
        }
    }

    private func onSelected() {
        errorHandler.handle {
            try await post.add(tag: tag)
        }
    }
}

private struct EditorRow: View {
    @EnvironmentObject private var errorHandler: ErrorHandler

    let tag: TagViewModel
    let post: PostViewModel

    var body: some View {
        VStack {
            HStack {
                Button(action: deleteTag) {
                    Checkmark(isChecked: true)
                }

                TagRow(tag: tag)
            }

            Divider()
        }
        .padding(.horizontal)
    }

    private func deleteTag() {
        errorHandler.handle {
            try await post.delete(tag: tag)
        }
    }
}

struct TagListEditor: View {
    @EnvironmentObject private var errorHandler: ErrorHandler

    @ObservedObject var post: PostViewModel

    var body: some View {
        ScrollView {
            VStack {
                ForEach(post.tags) {
                    EditorRow(tag: $0, post: post)
                }
            }
            .padding(.vertical)
        }
        .toolbar {
            NewTagButton { tag in
                errorHandler.handle {
                    try await post.add(tag: tag)
                }
            }
        }
        .tagSearch(exclude: post.tags) {
            TagSelectRow(tag: $0, post: post)
        }
    }
}

struct TagListEditorButton: View {
    @ObservedObject var post: PostViewModel

    @State private var isPresented = false

    var body: some View {
        Button(action: { isPresented = true }) {
            Label("Tags", systemImage: "tag")
        }
        .badge(post.tags.count)
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                TagListEditor(post: post)
                    .navigationTitle(post.tags.countOf(type: "Tag"))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            DismissButton()
                        }
                    }
            }
        }
    }
}

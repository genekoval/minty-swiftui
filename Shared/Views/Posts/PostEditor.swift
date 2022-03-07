import SwiftUI

struct PostEditor: View {
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var errorHandler: ErrorHandler

    @ObservedObject var post: PostViewModel

    @StateObject private var tagSearch = TagQueryViewModel()

    var body: some View {
        NavigationView {
            Form {
                EditorLink(
                    title: "Title",
                    onSave: { errorHandler.handle { try post.commitTitle() } },
                    draft: $post.draftTitle,
                    original: post.title
                )

                EditorLink(
                    title: "Description",
                    onSave: {
                        errorHandler.handle{ try post.commitDescription() }
                    },
                    draft: $post.draftDescription,
                    original: post.description
                )

                Section {
                    NavigationLink(destination: ObjectEditorGrid(
                        collection: post,
                        subscriber: post
                    )) {
                        HStack {
                            Label("Objects", systemImage: "doc")
                            Spacer()
                            Text("\(post.objects.count)")
                                .foregroundColor(.secondary)
                        }
                    }

                    NavigationLink(destination: TagSelector(
                        tags: $post.tags,
                        search: tagSearch,
                        onAdd: { tag in
                            errorHandler.handle { try post.addTag(tag: tag) }
                        },
                        onRemove: { tag in
                            errorHandler.handle { try post.removeTag(tag: tag) }
                        }
                    )) {
                        HStack {
                            Label("Tags", systemImage: "tag")
                            Spacer()
                            Text("\(post.tags.count)")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                DeleteButton(for: "Post") { delete() }
            }
            .navigationTitle("Edit Post")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                tagSearch.excluded = post.tags
            }
            .toolbar {
                Button(action: { dismiss() }) {
                    Text("Done")
                        .bold()
                }
            }
        }
    }

    private func delete() {
        errorHandler.handle {
            try post.delete()
            dismiss()
        }
    }
}

struct PostEditor_Previews: PreviewProvider {
    private static let post = PostViewModel.preview(id: "test")

    static var previews: some View {
        PostEditor(post: post)
            .withErrorHandling()
            .environmentObject(ObjectSource.preview)
    }
}

import SwiftUI

struct PostEditor: View {
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var errorHandler: ErrorHandler

    @ObservedObject var post: PostViewModel

    @StateObject private var postSearch = PostQueryViewModel()
    @StateObject private var tagSearch = TagQueryViewModel()

    var body: some View {
        NavigationView {
            Form {
                DraftEditorLink(
                    title: "Title",
                    original: post.title,
                    onSave: { errorHandler.handle { try post.commitTitle() } },
                    draft: $post.draftTitle
                )

                DraftEditorLink(
                    title: "Description",
                    original: post.description,
                    onSave: {
                        errorHandler.handle{ try post.commitDescription() }
                    },
                    draft: $post.draftDescription
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

                    NavigationLink(destination: RelatedPostsEditor(
                        post: post,
                        search: postSearch
                    )) {
                        HStack {
                            Label(
                                "Related Posts",
                                systemImage: "doc.text.image"
                            )
                            Spacer()
                            Text("\(post.posts.count)")
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
            .loadEntity(postSearch)
            .loadEntity(tagSearch)
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
    private static let post = PostViewModel.preview(id: PreviewPost.test)

    static var previews: some View {
        PostEditor(post: post)
            .withErrorHandling()
            .environmentObject(DataSource.preview)
            .environmentObject(ObjectSource.preview)
    }
}

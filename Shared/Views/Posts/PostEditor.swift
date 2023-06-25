import SwiftUI

struct PostEditor: View {
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var errorHandler: ErrorHandler

    @ObservedObject var post: PostViewModel

    @StateObject private var postSearch = PostQueryViewModel()
    @StateObject private var tagSearch = TagQueryViewModel()

    var body: some View {
        Form {
            DraftEditorLink(
                title: "Title",
                original: post.title,
                onSave: { try await post.commitTitle() },
                draft: $post.draftTitle
            )

            DraftEditorLink(
                title: "Description",
                original: post.description,
                onSave: { try await post.commitDescription() },
                draft: $post.draftDescription
            )

            Section {
                NavigationLink(destination: ObjectEditorGrid(post: post)) {
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
                        try await post.add(tag: tag)
                    },
                    onRemove: { tag in
                        try await post.removeTag(tag: tag)
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

            Section {
                if post.visibility == .draft {
                    Button("Publish Post") { create() }
                }

                DeleteButton(
                    for: post.visibility == .draft ? "Draft" : "Post"
                ) { delete() }
            }
        }
        .navigationTitle("\(post.visibility == .draft ? "New" : "Edit") Post")
        .navigationBarTitleDisplayMode(.inline)
        .loadEntity(postSearch)
        .loadEntity(tagSearch)
        .onAppear {
            tagSearch.excluded = post.tags
        }
    }

    private func create() {
        errorHandler.handle {
            try await post.createPost()
        }
    }

    private func delete() {
        errorHandler.handle {
            try await post.delete()
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

import SwiftUI

struct PostEditor: View {
    @EnvironmentObject var errorHandler: ErrorHandler

    @ObservedObject var post: PostViewModel

    var body: some View {
        Form {
            DraftEditor(
                draft: $post.draftTitle,
                original: post.title,
                title: "Title"
            ) { try await post.commitTitle() }

            DraftEditor(
                draft: $post.draftDescription,
                original: post.description,
                title: "Description"
            ) { try await post.commitDescription() }

            Section {
                ObjectEditorButton(post: post)
                RelatedPostsEditorButton(post: post)
                PostTagEditorButton(post: post)
            }

            Section {
                if post.visibility == .draft {
                    Button(action: create) {
                        Label("Publish Post", systemImage: "plus.circle")
                    }
                }

                DeleteButton(
                    for: post.visibility == .draft ? "Draft" : "Post",
                    action: delete
                )
            }
        }
        .playerSpacing()
    }

    private func create() {
        errorHandler.handle {
            try await post.createPost()
        }
    }

    private func delete() {
        errorHandler.handle {
            try await post.delete()
        }
    }
}

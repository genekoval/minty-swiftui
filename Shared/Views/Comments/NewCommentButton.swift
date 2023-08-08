import Minty
import SwiftUI

struct NewCommentButton: View {
    @EnvironmentObject private var data: DataSource
    @EnvironmentObject private var errorHandler: ErrorHandler

    let post: PostViewModel
    let onCreated: (Comment) -> Void

    @State private var draft = ""
    @State private var showingEditor = false

    var body: some View {
        Button(action: { showingEditor = true }) {
            Image(systemName: "plus.bubble")
        }
        .sheet(isPresented: $showingEditor) {
            CommentEditor(type: "New", draft: $draft, onDone: done)
        }
    }

    private func done() {
        errorHandler.handle {
            guard let repo = data.repo else {
                throw MintyError.unspecified(message: "Missing repo")
            }

            let result = try await repo.addComment(
                post: post.id,
                content: draft
            )

            draft.removeAll()

            onCreated(result)
        }
    }
}

import Minty
import SwiftUI

struct NewCommentButton: View {
    @EnvironmentObject private var data: DataSource
    @EnvironmentObject private var errorHandler: ErrorHandler

    let post: PostViewModel
    let onCreated: (CommentViewModel) -> Void

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
            let comment = try await data.addComment(to: post, content: draft)

            draft.removeAll()
            onCreated(comment)
        }
    }
}

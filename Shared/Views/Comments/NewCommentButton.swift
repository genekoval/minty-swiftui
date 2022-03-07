import Minty
import SwiftUI

struct NewCommentButton: View {
    @EnvironmentObject var errorHandler: ErrorHandler

    let post: PostViewModel

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
        errorHandler.handle { try post.add(comment: draft) }
    }
}

struct NewCommentButton_Previews: PreviewProvider {
    static var previews: some View {
        NewCommentButton(post: PostViewModel.preview(id: "test"))
            .withErrorHandling()
    }
}

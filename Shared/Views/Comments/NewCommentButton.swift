import Minty
import SwiftUI

struct NewCommentButton: View {
    @EnvironmentObject var errorHandler: ErrorHandler

    @ObservedObject var post: PostViewModel

    @State private var showingEditor = false

    var body: some View {
        Button(action: { showingEditor = true }) {
            Image(systemName: "plus.bubble")
        }
        .sheet(isPresented: $showingEditor) {
            CommentEditor(type: "New", draft: $post.draftComment, onDone: done)
        }
    }

    private func done() {
        errorHandler.handle { try post.comment() }
    }
}

struct NewCommentButton_Previews: PreviewProvider {
    static var previews: some View {
        NewCommentButton(post: PostViewModel.preview(id: PreviewPost.test))
            .withErrorHandling()
    }
}

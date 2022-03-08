import SwiftUI

struct CommentMenu: View {
    @EnvironmentObject var errorHandler: ErrorHandler

    @ObservedObject var comment: CommentViewModel

    @State private var showingEditor = false
    @State private var showingReplyEditor = false

    var body: some View {
        Menu {
            edit
            reply
        }
        label: {
            Image(systemName: "ellipsis.circle")
        }
        .sheet(isPresented: $showingEditor) {
            CommentEditor(type: "Edit", draft: $comment.draftContent) {
                errorHandler.handle { try comment.commitContent() }
            }
        }
        .sheet(isPresented: $showingReplyEditor) {
            CommentEditor(type: "New", draft: $comment.draftReply) {
                errorHandler.handle { try comment.reply() }
            }
        }
    }

    @ViewBuilder
    private var edit: some View {
        Button(action: { showingEditor = true }) {
            Label("Edit", systemImage: "pencil")
        }
    }

    @ViewBuilder
    private var reply: some View {
        Button(action: { showingReplyEditor = true }) {
            Label("Reply", systemImage: "arrowshape.turn.up.left")
        }
    }
}

struct CommentMenu_Previews: PreviewProvider {
    @ObservedObject private static var comment =
        CommentViewModel.preview(id: "long")

    static var previews: some View {
        CommentMenu(comment: comment)
            .withErrorHandling()
    }
}
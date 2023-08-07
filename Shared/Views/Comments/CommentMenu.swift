import SwiftUI

struct CommentMenu: View {
    @ObservedObject var comment: CommentViewModel

    @State private var showingEditor = false
    @State private var showingReplyEditor = false

    var body: some View {
        Menu {
            timestamp

            Divider()

            edit
            reply
            copy
        }
        label: {
            Image(systemName: "ellipsis.circle")
        }
        .sheet(isPresented: $showingEditor) {
            CommentEditor(type: "Edit", draft: $comment.draftContent) {
                try await comment.commitContent()
            }
        }
        .sheet(isPresented: $showingReplyEditor) {
            CommentEditor(type: "New", draft: $comment.draftReply) {
                try await comment.reply()
            }
        }
    }

    @ViewBuilder
    private var copy: some View {
        CopyID(entity: comment)
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

    @ViewBuilder
    private var timestamp: some View {
        Text(comment.created.formatted(date: .abbreviated, time: .standard))
    }
}

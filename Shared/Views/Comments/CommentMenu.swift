import Minty
import SwiftUI

struct CommentMenu: View {
    @EnvironmentObject private var data: DataSource

    @ObservedObject var comment: CommentViewModel

    let onReply: (Comment) -> Void

    @State private var showingEditor = false
    @State private var showingReplyEditor = false

    var body: some View {
        Menu {
            edit
            reply
            copy
        }
        label: {
            Image(systemName: "ellipsis.circle.fill")
                .symbolRenderingMode(.hierarchical)
        }
        .menuOrder(.priority)
        .sheet(isPresented: $showingEditor) {
            CommentEditor(type: "Edit", draft: $comment.draftContent) {
                try await saveChanges()
            }
        }
        .sheet(isPresented: $showingReplyEditor) {
            CommentEditor(type: "New", draft: $comment.draftReply) {
                try await addReply()
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

    private func addReply() async throws {
        guard let repo = data.repo else {
            throw MintyError.unspecified(message: "Missing repo")
        }

        let comment = try await repo.reply(
            to: comment.id,
            content: comment.draftReply
        )

        self.comment.draftReply.removeAll()

        onReply(comment)
    }

    private func saveChanges() async throws {
        guard comment.content != comment.draftContent else { return }

        guard let repo = data.repo else {
            throw MintyError.unspecified(message: "Missing repo")
        }

        comment.content = try await repo.set(
            comment: comment.id,
            content: comment.draftContent
        )
    }
}

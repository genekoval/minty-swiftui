import Minty
import SwiftUI

struct CommentMenu: View {
    @EnvironmentObject private var data: DataSource
    @EnvironmentObject private var errorHandler: ErrorHandler

    @ObservedObject var comment: CommentViewModel

    let onReply: (CommentViewModel) -> Void

    @State private var showingDelete = false
    @State private var showingDeleteTree = false
    @State private var showingEditor = false
    @State private var showingReplyEditor = false

    var body: some View {
        Menu {
            if !deleted { edit }
            reply
            copy

            Divider()

            if !deleted { delete }
            deleteTree
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
        .deleteConfirmation("this comment", isPresented: $showingDelete) {
            delete(recursive: false)
        }
        .deleteConfirmation(
            "this comment and all replies to it",
            isPresented: $showingDeleteTree
        ) {
            delete(recursive: true)
        }
    }

    @ViewBuilder
    private var copy: some View {
        CopyID(entity: comment)
    }

    @ViewBuilder
    private var delete: some View {
        Button(role: .destructive, action: { showingDelete = true }) {
            Label("Delete", systemImage: "trash")
        }
    }

    private var deleted: Bool {
        comment.content.isEmpty
    }

    @ViewBuilder
    private var deleteTree: some View {
        Button(role: .destructive, action: { showingDeleteTree = true }) {
            Label("Delete All", systemImage: "trash.circle")
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

    private func addReply() async throws {
        onReply(try await data.reply(to: comment))
    }

    private func delete(recursive: Bool) {
        errorHandler.handle {
            guard let repo = data.repo else {
                throw MintyError.unspecified(message: "Missing repo")
            }

            try await repo.delete(comment: comment.id, recursive: recursive)

            if recursive {
                CommentViewModel.deleted.send(comment.id)
            }
            else {
                withAnimation { comment.delete() }
            }
        }
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

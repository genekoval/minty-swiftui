import SwiftUI

struct PostContextMenu: ViewModifier {
    @EnvironmentObject private var errorHandler: ErrorHandler

    @ObservedObject var post: PostViewModel

    @State private var deletePresented = false

    @ViewBuilder
    private var delete: some View {
        Button(role: .destructive, action: { deletePresented = true }) {
            Label("Delete", systemImage: "trash")
        }
    }

    @ViewBuilder
    private var share: some View {
        ShareLink(item: post.id.uuidString)
    }

    func body(content: Content) -> some View {
        content
            .contextMenu {
                share
                Divider()
                delete
            }
            .deleteConfirmation("this post", isPresented: $deletePresented) {
                errorHandler.handle {
                    try await post.delete()
                }
            }
    }
}

extension View {
    func contextMenu(for post: PostViewModel) -> some View {
        modifier(PostContextMenu(post: post))
    }
}

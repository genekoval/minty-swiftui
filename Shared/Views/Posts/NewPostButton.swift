import Minty
import SwiftUI

private let icon = "square.and.pencil"

struct NewPostButton: View {
    @EnvironmentObject private var data: DataSource
    @EnvironmentObject private var errorHandler: ErrorHandler

    @Binding var draft: PostViewModel?

    @State private var showingPost = false

    let tag: TagViewModel?

    var body: some View {
        if let draft = draft, !draft.deleted, draft.visibility == .draft {
            NavigationLink(destination: PostHost(post: draft)) {
                Image(systemName: icon)
            }
            .navigationDestination(isPresented: $showingPost) {
                PostHost(post: draft)
            }
            .onReceive(draft.$deleted) { if $0 { self.draft = nil }}
            .onReceive(draft.$visibility) {
                if $0 != .draft {
                    self.draft = nil
                }
            }
        }
        else {
            Button(action: createDraft) {
                Image(systemName: icon)
            }
        }
    }

    private func createDraft() {
        errorHandler.handle {
            guard let repo = data.repo else { return }

            let id = try await repo.createPostDraft()
            let draft = data.state.posts.fetch(id: id)

            draft.app = data
            draft.isEditing = true
            draft.visibility = .draft

            if let tag = tag {
                try await draft.add(tag: tag)
            }

            self.draft = draft
            showingPost = true
        }
    }
}

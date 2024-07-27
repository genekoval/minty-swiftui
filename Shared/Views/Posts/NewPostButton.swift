import Minty
import SwiftUI

struct NewPostButton: View {
    @EnvironmentObject private var data: DataSource
    @EnvironmentObject private var errorHandler: ErrorHandler

    private let tag: TagViewModel?
    private let onCreated: ((PostViewModel) -> Void)?

    @State private var draft: PostViewModel?
    @State private var draftPresented = false

    var body: some View {
        Button(action: createDraft) {
            Image(systemName: "square.and.pencil")
        }
        .navigationDestination(isPresented: $draftPresented) {
            if let draft {
                PostHost(post: draft)
            }
        }
    }

    init(
        tag: TagViewModel? = nil,
        onCreated: ((PostViewModel) -> Void)? = nil
    ) {
        self.tag = tag
        self.onCreated = onCreated
    }

    private func createDraft() {
        errorHandler.handle {
            let draft = try await data.postDraft(tag: tag)

            onCreated?(draft)

            self.draft = draft
            draftPresented = true
        }
    }
}

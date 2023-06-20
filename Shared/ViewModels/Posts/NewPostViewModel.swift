import Combine
import Minty

final class NewPostViewModel: RemoteEntity, ObservableObject {
    @Published var draft: PostViewModel?

    private var cancellable: AnyCancellable?

    init() {
        super.init(identifier: "new post")

        cancellable = Post.deleted.sink { [weak self] in
            if $0 == self?.draft?.id { self?.draft = nil }
        }
    }

    func createDraft() async throws -> PostViewModel {
        try await withRepo("create draft") { repo in
            let id = try await repo.createPostDraft()
            let draft = app!.state.posts.fetch(id: id)

            draft.app = app
            draft.visibility = .draft

            self.draft = draft
        }

        return draft!
    }
}

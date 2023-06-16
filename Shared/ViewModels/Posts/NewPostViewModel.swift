import Combine

final class NewPostViewModel: RemoteEntity, ObservableObject {
    @Published var draft: PostViewModel?

    init() {
        super.init(identifier: "new post")
    }

    func createDraft() async throws -> PostViewModel {
        try await withRepo("create draft") { repo in
            let id = try await repo.createPostDraft()
            draft = app!.state.posts.fetch(id: id)
        }

        return draft!
    }
}

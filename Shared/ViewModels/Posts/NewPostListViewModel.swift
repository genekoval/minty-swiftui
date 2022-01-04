import Combine
import Minty

final class NewPostListViewModel: ObservableObject {
    @Published var posts: [PostPreview] = []
    @Published var selection: String?

    private var cancellables = Set<AnyCancellable>()

    init() {
        Events
            .postCreated
            .sink { [weak self] in self?.didCreate($0) }
            .store(in: &cancellables)

        Events
            .postDeleted
            .sink { [weak self] in self?.didDelete($0) }
            .store(in: &cancellables)
    }

    private func didCreate(_ postId: String) {
        var newPost = PostPreview()
        newPost.id = postId

        posts.append(newPost)
        selection = postId
    }

    private func didDelete(_ postId: String) {
        if let index = posts.firstIndex(where: { $0.id == postId }) {
            posts.remove(at: index)
        }
    }
}

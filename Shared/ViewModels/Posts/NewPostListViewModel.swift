import Combine
import Minty

final class NewPostListViewModel: ObservableObject {
    @Published var posts: [PostViewModel] = []
    @Published var selection: String?

    var data: DataSource?

    private var cancellables = Set<AnyCancellable>()

    init() {
        Post.created
            .sink { [weak self] in self?.didCreate($0) }
            .store(in: &cancellables)

        Post.deleted
            .sink { [weak self] in self?.didDelete($0) }
            .store(in: &cancellables)
    }

    private func didCreate(_ id: String) {
        guard let data = data else { return }

        let post = data.post(id: id)
        posts.append(post)
        selection = id
    }

    private func didDelete(_ postId: String) {
        posts.remove(id: postId)
    }
}

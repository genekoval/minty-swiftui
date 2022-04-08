import Combine
import Foundation
import Minty

typealias PostState = StateMap<PostViewModel>

final class DataSource: ObservableObject {
    typealias Connect = (Server) -> MintyRepo?

    @Published var repo: MintyRepo?

    private var cancellable: AnyCancellable?
    private let connect: Connect?

    private let posts = PostState()

    var count: Int {
        posts.count
    }

    init(connect: Connect? = nil, repo: MintyRepo? = nil) {
        self.connect = connect
        self.repo = repo
    }

    func observe(server: Published<Server?>.Publisher) {
        cancellable = server.sink { [weak self] in
            guard let self = self else { return }

            guard
                let value = $0,
                let repo = self.connect?(value)
            else {
                self.repo = nil
                return
            }

            self.repo = repo
        }
    }

    func post(id: String) -> PostViewModel {
        if let post = posts[id] {
            return post
        }

        let post = PostViewModel(id: id, storage: posts)
        posts[id] = post
        return post
    }

    func post(for preview: PostPreview) -> PostViewModel {
        let post = post(id: preview.id)
        post.load(from: preview)
        return post
    }
}

import Combine
import Foundation
import Minty

extension Minty.SortOrder {
    mutating func toggle() {
        self = self == .ascending ? .descending : .ascending
    }
}

extension PostQuery: Query { }

extension PostViewModel: SearchElement { }

final class PostQueryViewModel: Search<PostViewModel, PostQuery> {
    @Published var text = ""
    @Published var tags: [TagViewModel] = []
    @Published var visibility: Visibility = .pub

    private var cancellables = Set<AnyCancellable>()

    init(
        tag: TagViewModel? = nil,
        visibility: Visibility = .pub,
        searchNow: Bool = false
    ) {
        var query = PostQuery()

        query.size = 30
        query.sort.order = .descending
        query.sort.value = .dateCreated
        query.visibility = visibility

        if let tag = tag {
            query.tags.append(tag.id)
        }

        super.init(
            type: "post",
            query: query,
            deletionPublisher: Post.deleted,
            searchNow: searchNow
        ) { (repo, state, query) in
            let results = try await repo.getPosts(query: query)
            return (
                hits: results.hits.map { state.posts.fetch(for: $0) },
                total: Int(results.total)
            )
        }

        if let tag = tag {
            tags.append(tag)
        }

        $tags
            .dropFirst()
            .sink { [weak self] tags in
                self?.query.tags = tags.map { $0.id }
            }
            .store(in: &cancellables)

        self.visibility = visibility

        $visibility
            .dropFirst()
            .sink { [weak self] visibility in
                self?.query.visibility = visibility
            }
            .store(in: &cancellables)
    }
}

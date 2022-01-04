import Combine
import Foundation
import Minty

extension Minty.SortOrder {
    mutating func toggle() {
        self = self == .ascending ? .descending : .ascending
    }
}

extension PostQuery: Query { }

extension PostPreview: SearchElement { }

final class PostQueryViewModel: Search<PostPreview, PostQuery> {
    @Published var text = ""
    @Published var tags: [TagPreview] = []

    private var tagsCancellable: AnyCancellable?

    init(repo: MintyRepo?, tag: TagPreview? = nil, searchNow: Bool = false) {
        var query = PostQuery()

        query.size = 30
        query.sort.order = .descending
        query.sort.value = .dateCreated

        if let tag = tag {
            query.tags.append(tag.id)
        }

        super.init(
            type: "post",
            repo: repo,
            query: query,
            deletionPublisher: Events.postDeleted,
            searchNow: searchNow
        ) { (repo, query) in try repo.getPosts(query: query) }

        if let tag = tag {
            tags.append(tag)
        }

        tagsCancellable = $tags.dropFirst().sink { [weak self] tags in
            self?.query.tags = tags.map { $0.id }
        }
    }
}

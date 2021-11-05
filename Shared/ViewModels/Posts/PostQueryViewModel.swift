import Combine
import Foundation
import Minty

extension Minty.SortOrder {
    mutating func toggle() {
        self = self == .ascending ? .descending : .ascending
    }
}

final class PostQueryViewModel: RemoteEntity, ObservableObject {
    private var query = PostQuery()

    private var sortOrderCancellable: AnyCancellable?
    private var sortValueCancellable: AnyCancellable?
    private var tagsCancellable: AnyCancellable?
    private var textCancellable: AnyCancellable?

    @Published var initialSearch = false

    @Published var sortOrder = SortOrder.descending
    @Published var sortValue = PostQuery.Sort.SortValue.dateCreated
    @Published var tags: [TagPreview] = []
    @Published var text = ""

    @Published private(set) var hits: [PostPreview] = []
    @Published private(set) var total = 0

    var resultsAvailable: Bool {
        hits.count < total
    }

    init(repo: MintyRepo?) {
        super.init(identifier: "post query", repo: repo)

        query.size = 30

        sortOrderCancellable = $sortOrder.dropFirst().sink { [weak self] in
            self?.query.sort.order = $0
            self?.newSearch()
        }

        sortValueCancellable = $sortValue.dropFirst().sink { [weak self] in
            self?.query.sort.value = $0
            self?.newSearch()
        }

        tagsCancellable = $tags.dropFirst().sink { [weak self] in
            self?.query.tags = $0.map { $0.id }
            self?.newSearch()
        }

        textCancellable = $text.dropFirst().sink { [weak self] in
            self?.query.text = $0.isEmpty ? nil : $0
        }
    }

    private func clear() {
        query.from = 0
        total = 0
        hits.removeAll()
    }

    private func loadResult(result: SearchResult<PostPreview>) {
        total = Int(result.total)
        hits.append(contentsOf: result.hits)
    }

    func nextPage() {
        query.from += query.size
        search()
    }

    func newSearch() {
        clear()
        search()
    }

    func remove(id: String) {
        if let index = hits.firstIndex(where: { $0.id == id }) {
            hits.remove(at: index)
            total -= 1
        }
    }

    private func search() {
        withRepo("perform search") { repo in
            loadResult(result: try repo.getPosts(query: query))
            initialSearch = true
        }
    }
}

import Combine
import Minty
import Zipline

protocol Query {
    var from: UInt32 { get set }

    var size: UInt32 { get set }
}

protocol SearchElement : Identifiable, ZiplineCodable {
    var id: String { get }
}

class Search<Element, QueryType> : RemoteEntity, ObservableObject where
    Element: SearchElement, QueryType: Query
{
    typealias SearchAction =
        (MintyRepo, QueryType) throws -> SearchResult<Element>

    @Published var hits: [Element] = []
    @Published var initialSearch = false
    @Published var query: QueryType {
        didSet {
            if oldValue.from == query.from {
                newSearch()
            }
        }
    }

    @Published private(set) var total = 0

    private var queryCancellable: AnyCancellable?
    private let search: SearchAction

    final var resultsAvailable: Bool {
        hits.count < total
    }

    init(
        type: String,
        repo: MintyRepo?,
        query: QueryType,
        searchNow: Bool = false,
        search: @escaping SearchAction
    ) {
        self.query = query
        self.search = search

        super.init(identifier: "\(type) search", repo: repo)

        if searchNow {
            newSearch()
        }
    }

    private func clear() {
        if query.from != 0 {
            query.from = 0
        }

        total = 0
        hits.removeAll()
    }

    private func load(result: SearchResult<Element>) {
        total = Int(result.total)
        hits.append(contentsOf: result.hits)
    }

    private func newSearch() {
        clear()
        performSearch()
    }

    final func nextPage() {
        query.from += query.size
        performSearch()
    }

    private func performSearch() {
        withRepo("perform search") { repo in
            load(result: try search(repo, query))
            initialSearch = true
        }
    }

    final func remove(id: String) {
        if let index = hits.firstIndex(where: { $0.id == id }) {
            hits.remove(at: index)
            total -= 1
        }
    }
}

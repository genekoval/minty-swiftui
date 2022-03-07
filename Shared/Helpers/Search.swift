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

protocol SearchObject {
    func prepare(repo: MintyRepo?, errorHandler: ErrorHandler);
}

class Search<Element, QueryType> :
    RemoteEntity,
    ObservableObject,
    SearchObject
where
    Element: SearchElement,
    QueryType: Query
{
    typealias SearchAction =
        (MintyRepo, QueryType) throws -> SearchResult<Element>

    @Published var hits: [Element] = []
    @Published var query: QueryType {
        didSet {
            if !modifyingQuery {
                newSearch()
            }
        }
    }

    @Published private(set) var initialSearch = false
    @Published private(set) var total = 0

    private var deletionCancellable: AnyCancellable?
    private var errorHandler: ErrorHandler?
    private var modifyingQuery = false
    private let search: SearchAction
    private let searchNow: Bool

    final var resultsAvailable: Bool {
        hits.count < total
    }

    init(
        type: String,
        query: QueryType,
        deletionPublisher: PassthroughSubject<String, Never>,
        searchNow: Bool = false,
        search: @escaping SearchAction
    ) {
        self.query = query
        self.search = search
        self.searchNow = searchNow

        super.init(identifier: "\(type) search")

        deletionCancellable = deletionPublisher.sink { [weak self] in
            self?.remove(id: $0)
        }
    }

    final func clear() {
        modifyQuery { query.from = 0 }
        total = 0
        hits.removeAll()
    }

    override func refresh() throws {
        clear()
        if searchNow { performSearch() }
    }

    private func load(result: SearchResult<Element>) {
        total = Int(result.total)
        hits.append(contentsOf: result.hits)
    }

    final func modifyQuery(action: () -> Void) {
        modifyingQuery = true
        action()
        modifyingQuery = false
    }

    private func newSearch() {
        clear()
        performSearch()
    }

    final func nextPage() {
        modifyQuery { query.from += query.size }
        performSearch()
    }

    private func performSearch() {
        do {
            try withRepo("perform search") { repo in
                load(result: try search(repo, query))
                initialSearch = true
            }
        }
        catch {
            errorHandler?.handle(error: error)
        }
    }

    func prepare(repo: MintyRepo?, errorHandler: ErrorHandler) {
        self.errorHandler = errorHandler
        errorHandler.handle { try load(repo: repo) }
    }

    private func remove(id: String) {
        if let index = hits.firstIndex(where: { $0.id == id }) {
            hits.remove(at: index)
            total -= 1
        }
    }
}

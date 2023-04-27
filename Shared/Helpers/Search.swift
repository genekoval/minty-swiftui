import Combine
import Minty
import Zipline

protocol Query {
    var from: UInt32 { get set }

    var size: UInt32 { get set }
}

protocol SearchElement : Identifiable { }

protocol SearchObject {
    func prepare(app: DataSource, errorHandler: ErrorHandler) async
}

class Search<Element, QueryType> :
    RemoteEntity,
    ObservableObject,
    SearchObject
where
    Element: SearchElement,
    QueryType: Query
{
    typealias Result = (hits: [Element], total: Int)

    typealias SearchAction =
        (MintyRepo, AppState, QueryType) async throws -> Result

    @Published var hits: [Element] = []
    @Published var query: QueryType {
        didSet {
            if !modifyingQuery {
                Task.detached { [weak self] in
                    await self?.newSearch()
                }
            }
        }
    }

    @Published private(set) var resultsAvailable = false
    @Published private(set) var total = 0

    private var deletionCancellable: AnyCancellable?
    private var errorHandler: ErrorHandler?
    private var modifyingQuery = false
    private let search: SearchAction
    private let searchNow: Bool

    final var complete: Bool {
        hits.count == total
    }

    init(
        type: String,
        query: QueryType,
        deletionPublisher: PassthroughSubject<Element.ID, Never>,
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

    override func refresh() async throws {
        clear()
        if searchNow { await performSearch() }
    }

    private func load(result: Result) {
        hits.append(contentsOf: result.hits)
        total = result.total
    }

    final func modifyQuery(action: () -> Void) {
        modifyingQuery = true
        action()
        modifyingQuery = false
    }

    private func newSearch() async {
        resultsAvailable = false
        clear()
        await performSearch()
    }

    final func nextPage() async {
        modifyQuery { query.from += query.size }
        await performSearch()
    }

    private func performSearch() async {
        do {
            try await withRepo("perform search") { [self] repo in
                load(result: try await search(repo, app!.state, query))
                resultsAvailable = true
            }
        }
        catch {
            errorHandler?.handle(error: error)
        }
    }

    func prepare(app: DataSource, errorHandler: ErrorHandler) async {
        self.errorHandler = errorHandler
        errorHandler.handle { [weak self] in
            try await self?.load(app: app)
        }
    }

    private func remove(id: Element.ID) {
        if hits.remove(id: id) != nil {
            total -= 1
        }
    }
}

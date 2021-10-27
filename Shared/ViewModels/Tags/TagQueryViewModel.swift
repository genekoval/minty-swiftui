import Combine
import Foundation
import Minty

final class TagQueryViewModel: RemoteEntity, ObservableObject {
    private let size = 50

    private var cancellable: AnyCancellable?
    private var from = 0
    private var queryName = ""

    @Published var name = ""
    @Published var excluded: [TagPreview] = []
    @Published private(set) var total = 0
    @Published private(set) var hits: [TagPreview] = []

    var resultsAvailable: Bool {
        hits.count < total
    }

    private var query: TagQuery {
        var result = TagQuery()

        result.from = UInt32(from)
        result.size = UInt32(size)
        result.name = queryName
        result.exclude = excluded.map { $0.id }

        return result
    }

    init() {
        super.init(identifier: "tag query")

        cancellable = $name.sink() { [weak self] in
            self?.clear()

            if !$0.isEmpty {
                self?.queryName = $0
                self?.search()
            }
        }
    }

    private func clear() {
        from = 0
        total = 0
        hits.removeAll()
    }

    private func loadResult(result: SearchResult<TagPreview>) {
        total = Int(result.total)
        hits.append(contentsOf: result.hits)
    }

    func nextPage() {
        from += size
        search()
    }

    func remove(id: String) {
        if let index = excluded.firstIndex(where: { $0.id == id }) {
            excluded.remove(at: index)
        }

        if let index = hits.firstIndex(where: { $0.id == id }) {
            hits.remove(at: index)
            total -= 1
        }
    }

    private func search() {
        withRepo("perform search") { repo in
            loadResult(result: try repo.getTags(query: query))
        }
    }
}

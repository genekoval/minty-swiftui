import Combine
import Foundation
import Minty

final class TagQueryViewModel: ObservableObject {
    var repo: MintyRepo?

    @Published var from = 0
    @Published var size = 50
    @Published var name = ""
    @Published var exclude: [String] = []
    @Published var total = 0
    @Published var hits: [TagPreview] = []

    private var cancellable: AnyCancellable?

    var resultsAvailable: Bool {
        hits.count < total
    }

    init() {
        cancellable = $name.sink() { [weak self] in
            self?.clear()
            if !$0.isEmpty { self?.search(name: $0) }
        }
    }

    private func clear() {
        from = 0
        total = 0
        hits.removeAll()
    }

    func nextPage() {
        from += size
        search(name: name)
    }

    private func search(name: String) {
        guard let repo = repo else { return }

        var query = TagQuery()

        query.from = UInt32(from)
        query.size = UInt32(size)
        query.name = name
        query.exclude = exclude

        do {
            let result = try repo.getTags(query: query)
            total = Int(result.total)
            hits.append(contentsOf: result.hits)
        }
        catch {
            fatalError("Failed to get tags: \(error)")
        }
    }
}

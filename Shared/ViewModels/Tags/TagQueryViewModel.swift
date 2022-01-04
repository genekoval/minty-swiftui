import Combine
import Foundation
import Minty

extension TagQuery: Query { }

extension TagPreview: SearchElement { }

final class TagQueryViewModel: Search<TagPreview, TagQuery> {
    @Published var name = ""
    @Published var excluded: [TagPreview] = []

    private var cancellables = Set<AnyCancellable>()

    init(repo: MintyRepo?) {
        var query = TagQuery()

        query.size = 50

        super.init(
            type: "tag",
            repo: repo,
            query: query,
            deletionPublisher: Events.tagDeleted
        ) { (repo, query) in try repo.getTags(query: query) }

        Events
            .tagDeleted
            .sink { [weak self] in self?.remove(id: $0) }
            .store(in: &cancellables)

        $name
            .sink { [weak self] in self?.search(name: $0) }
            .store(in: &cancellables)

        $excluded
            .sink { [weak self] in self?.updateExcluded($0) }
            .store(in: &cancellables)
    }

    private func updateExcluded(_ tags: [TagPreview]) {
        modifyQuery { query.exclude = tags.map { $0.id } }
    }

    private func remove(id: String) {
        if let index = excluded.firstIndex(where: { $0.id == id }) {
            excluded.remove(at: index)
        }
    }

    private func search(name: String) {
        if name.isEmpty {
            clear()
        }
        else {
            query.name = name
        }
    }
}

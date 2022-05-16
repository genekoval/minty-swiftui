import Combine
import Foundation
import Minty

extension TagQuery: Query { }

extension TagPreview: SearchElement { }

final class TagQueryViewModel: Search<TagPreview, TagQuery> {
    @Published var name = ""
    @Published var excluded: [TagPreview] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        var query = TagQuery()

        query.size = 50

        super.init(
            type: "tag",
            query: query,
            deletionPublisher: Tag.deleted
        ) { (repo, query) in try repo.getTags(query: query) }

        Tag.deleted
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

    private func remove(id: UUID) {
        excluded.remove(id: id)
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

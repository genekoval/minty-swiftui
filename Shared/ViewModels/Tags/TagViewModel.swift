import Combine
import Foundation
import Minty

final class TagViewModel: ObservableObject {
    var id = ""
    var repo: MintyRepo? { didSet { load() } }

    @Published var name = ""
    @Published var aliases: [String] = []
    @Published var description: String?
    @Published var dateCreated = Date()
    @Published var sources: [Source] = []
    @Published var postCount: Int = 0

    private func load() {
        guard let repo = repo else { return }

        do {
            let tag = try repo.getTag(tagId: id)
            load(from: tag)
        }
        catch {
            fatalError("Failed to get tag: \(error)")
        }
    }

    private func load(from tag: Tag) {
        name = tag.name
        aliases = tag.aliases
        description = tag.description
        dateCreated = tag.dateCreated
        sources = tag.sources
        postCount = Int(tag.postCount)
    }
}

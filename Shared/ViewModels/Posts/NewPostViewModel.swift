import Combine
import Minty
import SwiftUI

final class NewPostViewModel: RemoteEntity, ObjectCollection, ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var objects: [ObjectPreview] = []
    @Published var tags: [TagViewModel] = []

    var isValid: Bool {
        !title.isWhitespace || !description.isWhitespace || !objects.isEmpty
    }

    var objectsPublisher: Published<[ObjectPreview]>.Publisher { $objects }

    private var parts: PostParts {
        var result = PostParts()

        result.title = title
        result.description = description
        result.objects = objects.map { $0.id }
        result.tags = tags.map { $0.id }

        return result
    }

    init(tag: TagViewModel? = nil) {
        super.init(identifier: "new post")

        if let tag = tag {
            tags.append(tag)
        }
    }

    func create() async throws -> UUID {
        var id: UUID?

        try await withRepo("create") { repo in
            id = try await repo.addPost(parts: parts)
        }

        return id!
    }
}

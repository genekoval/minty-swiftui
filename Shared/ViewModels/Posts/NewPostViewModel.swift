import Combine
import Minty
import SwiftUI

final class NewPostViewModel: RemoteEntity, ObjectCollection, ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var objects: [ObjectPreview] = []
    @Published var tags: [TagPreview] = []

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

    init(tag: TagPreview? = nil) {
        super.init(identifier: "new post")

        if let tag = tag {
            tags.append(tag)
        }
    }

    func create() throws {
        try withRepo("create") { repo in
            let id = try repo.addPost(parts: parts)
            Post.created.send(id)
        }
    }
}

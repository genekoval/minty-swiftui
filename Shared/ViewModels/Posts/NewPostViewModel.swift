import Combine
import Minty
import SwiftUI

final class NewPostViewModel: RemoteEntity, ObjectCollection, ObservableObject {
    @Published var draftTitle = ""
    @Published var draftDescription = ""
    @Published var objects: [ObjectPreview] = []
    @Published var tags: [TagPreview] = []

    @Published private(set) var title: String?
    @Published private(set) var description: String?

    private let newPost: PassthroughSubject<String, Never>

    var isValid: Bool {
        title != nil || description != nil || !objects.isEmpty
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

    init(
        repo: MintyRepo?,
        newPost: PassthroughSubject<String, Never>,
        tag: TagPreview? = nil
    ) {
        self.newPost = newPost

        super.init(identifier: "new post", repo: repo)

        if let tag = tag {
            tags.append(tag)
        }
    }

    func commitDescription() {
        description = processText(text: &draftDescription)
    }

    func commitTitle() {
        title = processText(text: &draftTitle)
    }

    func create() {
        withRepo("create") { repo in
            let postId = try repo.addPost(parts: parts)
            newPost.send(postId)
        }
    }

    private func processText(text: inout String) -> String? {
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }
}

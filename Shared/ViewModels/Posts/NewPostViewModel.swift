import Minty
import SwiftUI

final class NewPostViewModel: RemoteEntity, ObjectCollection, ObservableObject {
    @Published var draftTitle = ""
    @Published var draftDescription = ""
    @Published var objects: [ObjectPreview] = []
    @Published var tags: [TagPreview] = []

    @Published private(set) var title: String?
    @Published private(set) var description: String?

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

    init(repo: MintyRepo?) {
        super.init(identifier: "new post", repo: repo)
    }

    func commitDescription() {
        description = processText(text: &draftDescription)
    }

    func commitTitle() {
        title = processText(text: &draftTitle)
    }

    func create() -> String? {
        var result: String?

        withRepo("create") { repo in
            result = try repo.addPost(parts: parts)
        }

        return result
    }

    private func processText(text: inout String) -> String? {
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }
}

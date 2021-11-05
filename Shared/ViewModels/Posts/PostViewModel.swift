import Combine
import Foundation
import Minty

final class PostViewModel: IdentifiableEntity, ObservableObject {
    @Published private(set) var title: String?
    @Published private(set) var description: String?
    @Published private(set) var created: Date = Date()
    @Published private(set) var modified: Date = Date()
    @Published private(set) var objects: [ObjectPreview] = []
    @Published private(set) var tags: [TagPreview] = []

    @Published var deletedTag: String?

    private var deletedTagCancellable: AnyCancellable?

    init(id: String, repo: MintyRepo?) {
        super.init(id: id, identifier: "post", repo: repo)

        deletedTagCancellable = $deletedTag.sink { [weak self] in
            if let id = $0 {
                self?.removeLocalTag(id: id)
            }
        }
    }

    private func load(from post: Post) {
        title = post.title
        description = post.description
        created = post.dateCreated
        modified = post.dateModified
        objects = post.objects
        tags = post.tags
    }

    override func refresh() {
        withRepo("fetch data") { repo in
            load(from: try repo.getPost(postId: id))
        }
    }

    private func removeLocalTag(id: String) {
        if let index = tags.firstIndex(where: { $0.id == id }) {
            tags.remove(at: index)
        }
    }
}

import Combine
import Foundation
import Minty

final class PostViewModel: IdentifiableEntity, ObservableObject {
    let deletedTag = Deleted()

    @Published var draftTitle = ""
    @Published var draftDescription = ""

    @Published var tags: [TagPreview] = []

    @Published private(set) var title: String?
    @Published private(set) var description: String?
    @Published private(set) var created: Date = Date()
    @Published private(set) var modified: Date = Date()
    @Published private(set) var objects: [ObjectPreview] = []
    @Published private(set) var preview: PostPreview

    private let deleted: Deleted

    private var cancellables = Set<AnyCancellable>()

    init(
        id: String,
        repo: MintyRepo?,
        deleted: Deleted,
        preview: PostPreview
    ) {
        self.deleted = deleted
        self.preview = preview

        super.init(id: id, identifier: "post", repo: repo)

        deletedTag.$id.sink { [weak self] in
            if let id = $0 {
                self?.removeLocalTag(id: id)
            }
        }.store(in: &cancellables)

        $title.sink { [weak self] in
            self?.draftTitle = $0 ?? ""
            self?.preview.title = $0
        }.store(in: &cancellables)

        $description.sink { [weak self] in
            self?.draftDescription = $0 ?? ""
        }.store(in: &cancellables)
    }

    func addTag(tag: TagPreview) {
        withRepo("add tag") { repo in
            try repo.addPostTag(postId: id, tagId: tag.id)
        }
    }

    func commitDescription() {
        withRepo("set description") { repo in
            let update = try repo.setPostDescription(
                postId: id,
                description: draftDescription
            )

            description = update.newValue
            modified = update.modified
        }
    }

    func commitTitle() {
        withRepo("set title") { repo in
            let update = try repo.setPostTitle(postId: id, title: draftTitle)

            title = update.newValue
            modified = update.modified
        }
    }

    func delete() {
        withRepo("delete post") { repo in
            try repo.deletePost(postId: id)
        }

        deleted.id = id
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

    func removeTag(tag: TagPreview) {
        withRepo("delete tag") { repo in
            try repo.deletePostTag(postId: id, tagId: tag.id)
        }
    }
}

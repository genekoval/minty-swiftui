import Combine
import Foundation
import Minty

final class PostViewModel:
    IdentifiableEntity,
    ObjectCollection,
    ObjectEditorSubscriber,
    ObservableObject
{
    @Published var draftTitle = ""
    @Published var draftDescription = ""
    @Published var objects: [ObjectPreview] = []
    @Published var tags: [TagPreview] = []

    @Published private(set) var deleted = false
    @Published private(set) var title: String?
    @Published private(set) var description: String?
    @Published private(set) var created: Date = Date()
    @Published private(set) var modified: Date = Date()
    @Published private(set) var preview: PostPreview
    @Published private(set) var comments: [Comment] = []

    private var cancellables = Set<AnyCancellable>()

    var objectsPublisher: Published<[ObjectPreview]>.Publisher { $objects }

    init(id: String, repo: MintyRepo?, preview: PostPreview) {
        self.preview = preview

        super.init(id: id, identifier: "post", repo: repo)

        Events
            .postDeleted
            .sink { [weak self] in self?.postDeleted(id: $0) }
            .store(in: &cancellables)

        Events
            .tagDeleted
            .sink { [weak self] in self?.removeLocalTag(id: $0)}
            .store(in: &cancellables)

        $title.sink { [weak self] in
            self?.draftTitle = $0 ?? ""
            self?.preview.title = $0
        }.store(in: &cancellables)

        $description.sink { [weak self] in
            self?.draftDescription = $0 ?? ""
        }.store(in: &cancellables)

        $objects.sink { [weak self] in
            self?.preview.previewId = $0.first?.previewId
            self?.preview.objectCount = UInt32($0.count)
        }.store(in: &cancellables)
    }

    func add(comment: String) {
        withRepo("add comment") { repo in
            let result = try repo.addComment(
                postId: id,
                parentId: nil,
                content: comment
            )

            comments.insert(result, at: 0)
        }
    }

    func add(objects: [String], at position: Int) {
        withRepo("add objects") { repo in
            modified = try repo.addPostObjects(
                postId: id,
                objects: objects,
                position: UInt32(position)
            )
        }
    }

    func add(reply: Comment, to parentId: String) {
        guard let index = comments.firstIndex(where: { $0.id == parentId })
        else {
            fatalError("Parent comment does not exist")
        }

        comments.insert(reply, at: index + 1)
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

        Events.postDeleted.send(id)
    }

    func delete(objects: [String]) {
        withRepo("delete objects") { repo in
            modified = try repo.deletePostObjects(postId: id, objects: objects)
        }
    }

    private func fetchComments() {
        withRepo("fetch comments") { repo in
            comments = try repo.getComments(postId: id)
        }
    }

    private func fetchData() {
        withRepo("fetch data") { repo in
            load(from: try repo.getPost(postId: id))
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

    func move(objects: [String], to destination: String?) {
        withRepo("move objects") { repo in
            modified = try repo.movePostObjects(
                postId: id,
                objects: objects,
                destination: destination
            )
        }
    }

    private func postDeleted(id: String) {
        if id == self.id {
            deleted = true
        }
    }

    override func refresh() {
        fetchData()
        fetchComments()
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

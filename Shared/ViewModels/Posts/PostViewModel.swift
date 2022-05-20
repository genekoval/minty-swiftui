import Combine
import Foundation
import Minty

final class PostViewModel:
    IdentifiableEntity,
    ObjectCollection,
    ObjectEditorSubscriber,
    ObjectProvider,
    ObservableObject,
    StorableEntity
{
    @Published var draftTitle = ""
    @Published var draftDescription = ""
    @Published var objects: [ObjectPreview] = []
    @Published var tags: [TagViewModel] = []

    @Published private(set) var deleted = false
    @Published private(set) var title: String?
    @Published private(set) var description: String?
    @Published private(set) var created: Date = Date()
    @Published private(set) var modified: Date = Date()
    @Published private(set) var comments: [Comment] = []
    @Published private(set) var preview: ObjectPreview?
    @Published private(set) var commentCount: Int = 0
    @Published private(set) var objectCount: Int = 0
    @Published private(set) var posts: [PostViewModel] = []

    private var cancellables = Set<AnyCancellable>()
    private weak var storage: PostState?

    var objectsPublisher: Published<[ObjectPreview]>.Publisher { $objects }

    init(id: UUID, storage: PostState?) {
        super.init(id: id, identifier: "post")

        self.storage = storage

        Post.deleted
            .sink { [weak self] in self?.postDeleted(id: $0) }
            .store(in: &cancellables)

        Tag.deleted
            .sink { [weak self] in self?.removeLocalTag(id: $0)}
            .store(in: &cancellables)

        $title.sink { [weak self] in
            self?.draftTitle = $0 ?? ""
        }.store(in: &cancellables)

        $description.sink { [weak self] in
            self?.draftDescription = $0 ?? ""
        }.store(in: &cancellables)

        $objects.sink { [weak self] in
            self?.objectCount = $0.count
            self?.preview = $0.first
        }.store(in: &cancellables)

        $comments.sink { [weak self] in
            self?.commentCount = $0.count
        }.store(in: &cancellables)
    }

    deinit {
        if let storage = storage {
            storage.remove(self)
        }
    }

    func add(comment: String) throws {
        try withRepo("add comment") { repo in
            let result = try repo.addComment(postId: id, content: comment)
            comments.insert(result, at: 0)
        }
    }

    func add(objects: [UUID], at position: Int) throws {
        try withRepo("add objects") { repo in
            modified = try repo.addPostObjects(
                postId: id,
                objects: objects,
                position: Int16(position)
            )
        }
    }

    func add(post: PostViewModel) throws {
        try withRepo("add related post") { repo in
            try repo.addRelatedPost(postId: id, related: post.id)
        }

        posts.append(post)
    }

    func add(reply: Comment, to parentId: UUID) throws {
        guard let index = comments.firstIndex(where: { $0.id == parentId })
        else {
            throw MintyError.unspecified(
                message: "Parent comment does not exist"
            )
        }

        comments.insert(reply, at: index + 1)
    }

    func addTag(tag: TagViewModel) throws {
        try withRepo("add tag") { repo in
            try repo.addPostTag(postId: id, tagId: tag.id)
        }
    }

    func commitDescription() throws {
        try withRepo("set description") { repo in
            let update = try repo.setPostDescription(
                postId: id,
                description: draftDescription
            )

            description = update.newValue
            modified = update.modified
        }
    }

    func commitTitle() throws {
        try withRepo("set title") { repo in
            let update = try repo.setPostTitle(postId: id, title: draftTitle)

            title = update.newValue
            modified = update.modified
        }
    }

    func delete() throws {
        try withRepo("delete post") { repo in
            try repo.deletePost(postId: id)
        }

        Post.deleted.send(id)
    }

    func delete(objects: [UUID]) throws {
        try withRepo("delete objects") { repo in
            modified = try repo.deletePostObjects(postId: id, objects: objects)
        }
    }

    func delete(post: PostViewModel) throws {
        try withRepo("delete related post") { repo in
            try repo.deleteRelatedPost(postId: id, related: post.id)
        }

        posts.remove(id: post.id)
    }

    private func fetchComments() throws {
        try withRepo("fetch comments") { repo in
            comments = try repo.getComments(postId: id)
        }
    }

    private func fetchData() throws {
        try withRepo("fetch data") { repo in
            load(try repo.getPost(postId: id))
        }
    }

    private func load(_ post: Post) {
        title = post.title
        description = post.description
        created = post.dateCreated
        modified = post.dateModified
        objects = post.objects
        posts = post.posts.map { app!.state.posts.fetch(for: $0) }
        tags = post.tags.map { app!.state.tags.fetch(for: $0) }
    }

    func load(from preview: PostPreview) {
        title = preview.title
        self.preview = preview.preview
        commentCount = Int(preview.commentCount)
        objectCount = Int(preview.objectCount)
        created = preview.dateCreated
    }

    func move(objects: [UUID], to destination: UUID?) throws {
        try withRepo("move objects") { repo in
            modified = try repo.movePostObjects(
                postId: id,
                objects: objects,
                destination: destination
            )
        }
    }

    private func postDeleted(id: UUID) {
        if id == self.id {
            deleted = true
        }
    }

    override func refresh() throws {
        try fetchData()
        try fetchComments()
    }

    private func removeLocalTag(id: UUID) {
        tags.remove(id: id)
    }

    func removeTag(tag: TagViewModel) throws {
        try withRepo("delete tag") { repo in
            try repo.deletePostTag(postId: id, tagId: tag.id)
        }
    }
}

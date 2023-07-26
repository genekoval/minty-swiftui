import Combine
import Foundation
import Minty
import SwiftUI

final class PostViewModel:
    IdentifiableEntity,
    ObjectProvider,
    ObservableObject,
    StorableEntity
{
    static let placeholder: PostViewModel = {
        let id = UUID()
        let post = PostViewModel(id: id, storage: nil)

        post.title = .placeholder(count: 100)

        return post
    }()

    @Published var draftTitle = ""
    @Published var draftDescription = ""
    @Published var draftComment = ""
    @Published var isEditing = false
    @Published var objects: [ObjectPreview] = []
    @Published var tags: [TagViewModel] = []
    @Published var visibility: Minty.Visibility = .invalid

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

    func add(objects: [ObjectPreview]) async throws {
        try await withRepo("add objects") { repo in
            modified = try await repo.add(
                post: id,
                objects: objects.map { $0.id }
            )

            for object in objects {
                if let index = self.objects.firstIndex(of: object) {
                    self.objects.remove(at: index)
                }
            }

            self.objects.append(contentsOf: objects)
        }
    }

    func insert(
        objects: [ObjectPreview],
        before destination: ObjectPreview
    ) async throws {
        try await withRepo("insert objects") { repo in
            modified = try await repo.insert(
                post: id,
                objects: objects.map { $0.id },
                before: destination.id
            )

            for object in objects {
                if let index = self.objects.firstIndex(of: object) {
                    self.objects.remove(at: index)
                }
            }

            if let index = self.objects.firstIndex(of: destination) {
                self.objects.insert(contentsOf: objects, at: index)
            }
            else {
                self.objects.append(contentsOf: objects)
            }
        }
    }

    func add(post: PostViewModel) async throws {
        try await withRepo("add related post") { repo in
            try await repo.addRelatedPost(post: id, related: post.id)
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

    func add(tag: TagViewModel) async throws {
        try await withRepo("add tag") { repo in
            try await repo.addPostTag(post: id, tag: tag.id)
        }

        tags.append(tag)
    }

    func comment() async throws {
        try await withRepo("add comment") { repo in
            let result = try await repo.addComment(
                post: id,
                content: draftComment
            )

            comments.insert(result, at: 0)
            draftComment.removeAll()
        }
    }

    func commitDescription() async throws {
        try await withRepo("set description") { repo in
            let update = try await repo.set(
                post: id,
                description: draftDescription
            )

            description = update.value
            modified = update.modified
        }
    }

    func commitTitle() async throws {
        try await withRepo("set title") { repo in
            let update = try await repo.set(
                post: id,
                title: draftTitle
            )

            title = update.value
            modified = update.modified
        }
    }

    func createPost() async throws {
        try await withRepo("create post") { repo in
            try await repo.createPost(draft: id)
            try await refresh()
            isEditing = false
        }
    }

    func delete() async throws {
        try await withRepo("delete post") { repo in
            try await repo.delete(post: id)
        }

        withAnimation {
            Post.deleted.send(id)
        }
    }

    func delete(objects: [ObjectPreview]) async throws {
        try await withRepo("delete objects") { repo in
            modified = try await repo.delete(
                post: id,
                objects: objects.map { $0.id }
            )

            self.objects.remove(all: objects)
        }
    }

    func delete(tag: TagViewModel) async throws {
        try await withRepo("delete tag") { repo in
            try await repo.delete(post: id, tag: tag.id)
            tags.remove(element: tag)
        }
    }

    func delete(tags: IndexSet) async throws {
        for index in tags {
            let tag = self.tags[index]
            try await removeTag(tag: tag)
        }

        self.tags.remove(atOffsets: tags)
    }

    func delete(post: PostViewModel) async throws {
        try await withRepo("delete related post") { repo in
            try await repo.delete(post: id, related: post.id)
        }

        posts.remove(id: post.id)
    }

    private func fetchComments() async throws {
        try await withRepo("fetch comments") { repo in
            comments = try await repo.getComments(for: id)
        }
    }

    private func fetchData() async throws {
        try await withRepo("fetch data") { repo in
            load(try await repo.get(post: id))
        }
    }

    private func load(_ post: Post) {
        title = post.title
        description = post.description
        visibility = post.visibility
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

    private func postDeleted(id: UUID) {
        if id == self.id {
            deleted = true
        }
    }

    override func refresh() async throws {
        try await fetchData()
        try await fetchComments()
    }

    private func removeLocalTag(id: UUID) {
        tags.remove(id: id)
    }

    func removeTag(tag: TagViewModel) async throws {
        try await withRepo("delete tag") { repo in
            try await repo.delete(post: id, tag: tag.id)
        }
    }
}

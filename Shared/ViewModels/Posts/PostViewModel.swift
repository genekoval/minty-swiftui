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
        let post = PostViewModel(id: UUID(), storage: nil)

        post.title = .placeholder(count: 100)

        return post
    }()

    #if DEBUG
    fileprivate static func generate(count: Int) -> [PostViewModel] {
        var result: [PostViewModel] = []
        result.reserveCapacity(count)

        for i in 1...count {
            let post = PostViewModel(id: UUID(), storage: nil)
            post.title = "Post #\(i)"
            result.append(post)
        }

        return result
    }
    #endif

    @Published var commentCount: Int = 0
    @Published var draftTitle = ""
    @Published var draftDescription = ""
    @Published var isEditing = false
    @Published var objects: [ObjectPreview] = []
    @Published var tags: [TagViewModel] = []
    @Published var visibility: Minty.Visibility = .invalid

    @Published private(set) var deleted = false
    @Published private(set) var title = ""
    @Published private(set) var description = ""
    @Published private(set) var created: Date = Date()
    @Published private(set) var modified: Date = Date()
    @Published private(set) var preview: ObjectPreview?
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

        $title
            .sink { [weak self] in self?.draftTitle = $0 }
            .store(in: &cancellables)

        $description
            .sink { [weak self] in self?.draftDescription = $0 }
            .store(in: &cancellables)

        $objects.sink { [weak self] in
            self?.objectCount = $0.count
            self?.preview = $0.first
        }.store(in: &cancellables)
    }

    deinit {
        if let storage = storage {
            storage.remove(self)
        }
    }

    func add(objects: [ObjectPreview]) async throws {
        try await withRepo("add objects") { repo in
            modified = try await repo.appendPostObjects(
                post: id,
                objects: objects.map { $0.id }
            )

            for object in objects {
                if let index = self.objects.firstIndex(of: object) {
                    self.objects.remove(at: index)
                }
            }

            withAnimation {
                self.objects.append(contentsOf: objects)
            }
        }
    }

    func insert(
        objects: [ObjectPreview],
        before destination: ObjectPreview
    ) async throws {
        try await withRepo("insert objects") { repo in
            modified = try await repo.insertPostObjects(
                id: id,
                objects: objects.map { $0.id },
                before: destination.id
            )

            withAnimation {
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
    }

    func add(post: PostViewModel) async throws {
        try await withRepo("add related post") { repo in
            try await repo.addRelatedPost(post: id, related: post.id)
        }

        posts.append(post)
    }

    func add(tag: TagViewModel) async throws {
        try await withRepo("add tag") { repo in
            try await repo.addPostTag(post: id, tag: tag.id)
        }

        tags.append(tag)
    }

    func commitDescription() async throws {
        draftDescription = draftDescription
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard draftDescription != description else { return }

        try await withRepo("set description") { repo in
            let update = try await repo.setPostDescription(
                id: id,
                description: draftDescription
            )

            description = update.newValue
            modified = update.dateModified
        }
    }

    func commitTitle() async throws {
        draftTitle = draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard draftTitle != title else { return }

        try await withRepo("set title") { repo in
            let update = try await repo.setPostTitle(
                id: id,
                title: draftTitle
            )

            title = update.newValue
            modified = update.dateModified
        }
    }

    func createPost() async throws {
        try await withRepo("create post") { repo in
            try await repo.publishPost(id: id)
            try await refresh()

            isEditing = false

            for tag in tags {
                withAnimation { tag.postCount += 1 }
            }

            Post.published.send(self)
        }
    }

    func delete() async throws {
        try await withRepo("delete post") { repo in
            try await repo.deletePost(id: id)
        }

        for tag in tags {
            withAnimation { tag.postCount -= 1 }
        }

        withAnimation {
            Post.deleted.send(id)
        }
    }

    func delete(objects: [ObjectPreview]) async throws {
        try await withRepo("delete objects") { repo in
            modified = try await repo.deletePostObjects(
                id: id,
                objects: objects.map { $0.id }
            )

            self.objects.remove(all: objects)
        }
    }

    func delete(tag: TagViewModel) async throws {
        try await withRepo("delete tag") { repo in
            try await repo.deletePostTag(id: id, tag: tag.id)
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
            try await repo.deleteRelatedPost(id: id, related: post.id)
        }

        posts.remove(id: post.id)
    }

    private func load(_ post: Post) {
        title = post.title
        description = post.description
        visibility = post.visibility
        created = post.created
        modified = post.modified
        objects = post.objects
        posts = post.posts.map { app!.state.posts.fetch(for: $0) }
        tags = post.tags.map { app!.state.tags.fetch(for: $0) }
        commentCount = post.commentCount
    }

    func load(from preview: PostPreview) {
        title = preview.title
        self.preview = preview.preview
        commentCount = preview.commentCount
        objectCount = preview.objectCount
        created = preview.created
    }

    private func postDeleted(id: UUID) {
        if id == self.id {
            deleted = true
        }
    }

    override func refresh() async throws {
        try await withRepo("fetch data") { repo in
            load(try await repo.getPost(id: id))
        }
    }

    private func removeLocalTag(id: UUID) {
        tags.remove(id: id)
    }

    func removeTag(tag: TagViewModel) async throws {
        try await withRepo("delete tag") { repo in
            try await repo.deletePostTag(id: id, tag: tag.id)
        }
    }
}

#if DEBUG
extension Array where Element == PostViewModel {
    @MainActor
    static func generate(count: Int) -> Self {
        return PostViewModel.generate(count: count)
    }
}
#endif

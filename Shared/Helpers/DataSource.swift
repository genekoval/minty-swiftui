import Combine
import Foundation
import Minty

enum ServerStatus {
    case connected(about: About)
    case error(message: String, detail: String)
}

final class DataSource: ObservableObject {
    typealias Connect = (URL) async throws -> MintyRepo

    let state = AppState()
    var onFailedConnection: ((Error) -> Void)?

    @Published var repo: MintyRepo?
    @Published private(set) var connecting = false
    @Published private(set) var server: ServerStatus?

    private var cancellable: AnyCancellable?
    private let connectAction: Connect

    init(connect: @escaping Connect) {
        connectAction = connect
    }

    func addComment(
        to post: PostViewModel,
        content: String
    ) async throws -> CommentViewModel {
        guard let repo else { preconditionFailure("Missing repo") }

        let comment = try await repo.addComment(post: post.id, content: content)
        return state.comments.fetch(for: comment)
    }

    func addTag(name: String) async throws -> TagViewModel {
        guard let repo else { preconditionFailure("Missing repo") }

        let id = try await repo.addTag(name: name)
        return state.tags.fetch(id: id)
    }

    @MainActor
    private func connect(to server: URL) async {
        connecting = true
        defer { connecting = false }

        do {
            let repo = try await connectAction(server)
            let about = try await repo.about()

            self.repo = repo
            self.server = .connected(about: about)
        }
        catch {
            self.server = .error(
                message: "Connection Failure",
                detail: error.localizedDescription
            )
            onFailedConnection?(MintyError.other(
                message: "Couldn't connect to the server."
            ))
        }
    }

    @MainActor
    func getComments(
        for post: PostViewModel
    ) async throws -> [CommentViewModel] {
        guard let repo else { return [] }

        let results = try await repo.getComments(for: post.id)

        let comments = fetchComments(for: results)
        comments.forEach { $0.post = post }

        return comments
    }

    @MainActor
    private func fetchComments(
        for comments: [CommentData]
    ) -> [CommentViewModel] {
        return comments.map { state.comments.fetch(for: $0) }
    }

    @MainActor
    private func fetchPost(for preview: PostPreview) -> PostViewModel {
        let post = state.posts.fetch(for: preview)
        post.app = self
        return post
    }

    @MainActor
    private func fetchTag(for preview: TagPreview) -> TagViewModel {
        let tag = state.tags.fetch(for: preview)
        tag.app = self
        return tag
    }

    @MainActor
    func findPosts(
        text: String? = nil,
        tags: [TagViewModel] = [],
        visibility: Minty.Visibility = .pub,
        sort: PostQuery.Sort = .created,
        from: Int = 0,
        size: Int
    ) async throws -> (hits: [PostViewModel], total: Int) {
        guard let repo else { return (hits: [], total: 0) }

        let results = try await repo.getPosts(query: PostQuery(
            from: from,
            size: size,
            text: text ?? "",
            tags: tags.map { $0.id },
            visibility: visibility,
            sort: sort
        ))

        let posts = results.hits.map { fetchPost(for: $0) }

        for post in posts {
            post.tags.appendUnique(contentsOf: tags)
        }

        return (
            hits: posts,
            total: results.total
        )
    }

    @MainActor
    func findTags(
        _ name: String,
        exclude: [TagViewModel],
        from: Int = 0,
        size: Int
    ) async throws -> (hits: [TagViewModel], total: Int) {
        guard let repo else { return (hits: [], total: 0) }

        let results = try await repo.getTags(query: TagQuery(
            from: from,
            size: size,
            name: name,
            exclude: exclude.map { $0.id }
        ))

        return (
            hits: results.hits.map { fetchTag(for: $0) },
            total: results.total
        )
    }

    func observe(server: Published<URL?>.Publisher) {
        cancellable = server.sink { [weak self] in
            guard
                let self = self,
                let server = $0
            else {
                self?.repo = nil
                self?.server = nil

                return
            }

            Task {
                await self.connect(to: server)
            }
        }
    }

    @MainActor
    func postDraft(tag: TagViewModel? = nil) async throws -> PostViewModel {
        guard let repo else { preconditionFailure("Missing repo") }

        var tags: [UUID]? = nil
        if let tag {
            tags = [tag.id]
        }

        let id = try await repo.createPost(parts: .init(
            visibility: .draft,
            tags: tags
        ))
        let draft = state.posts.fetch(id: id)

        draft.app = self
        draft.isEditing = true
        draft.visibility = .draft

        return draft
    }


    @MainActor
    func reply(to comment: CommentViewModel) async throws -> CommentViewModel {
        guard let repo else { preconditionFailure("Missing repo") }

        let result = try await repo.reply(
            to: comment.id,
            content: comment.draftReply
        )

        comment.draftReply.removeAll()

        return state.comments.fetch(for: result)
    }
}

import Combine
import Foundation
import Minty

enum ServerStatus {
    case connected(version: String)
    case error(message: String, detail: String)
}

final class DataSource: ObservableObject {
    typealias Connect = (Server) async throws -> MintyRepo

    let state = AppState()
    var onFailedConnection: ((Error) -> Void)?

    @Published var repo: MintyRepo?
    @Published private(set) var connecting = false
    @Published private(set) var server: ServerStatus?

    private var cancellable: AnyCancellable?
    private let connectAction: Connect?

    init(connect: @escaping Connect) {
        connectAction = connect
    }

    func addTag(name: String) async throws -> TagViewModel {
        guard let repo else { preconditionFailure("Missing repo") }

        let id = try await repo.addTag(name: name)
        return state.tags.fetch(id: id)
    }

    @MainActor
    private func connect(server: Server) async {
        guard let connect = connectAction else { return }

        connecting = true

        do {
            let repo = try await connect(server)

            self.repo = repo
            self.server = .connected(version: repo.version)
        }
        catch {
            self.server = .error(
                message: "Connection Failure",
                detail: error.localizedDescription
            )
            onFailedConnection?(MintyError.unspecified(
                message: "Couldn't connect to the server."
            ))
        }

        connecting = false
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
            text: text,
            tags: tags.map { $0.id },
            visibility: visibility,
            sort: sort
        ))

        return (
            hits: results.hits.map { fetchPost(for: $0) },
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

    func observe(server: Published<Server?>.Publisher) {
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
                await self.connect(server: server)
            }
        }
    }

    @MainActor
    func postDraft(tag: TagViewModel? = nil) async throws -> PostViewModel {
        guard let repo else { preconditionFailure("Missing repo") }

        let id = try await repo.createPostDraft()
        let draft = state.posts.fetch(id: id)

        draft.app = self
        draft.isEditing = true
        draft.visibility = .draft

        if let tag {
            try await draft.add(tag: tag)
        }

        return draft
    }
}

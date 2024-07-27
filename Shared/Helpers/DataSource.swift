import Combine
import Foundation
import Minty
import os

enum ServerStatus {
    case connected(about: About)
    case error(message: String, detail: String)
}

final class DataSource: ObservableObject {
    let settings = SettingsViewModel()
    let state = AppState()

    @Published var repo: MintyRepo?
    @Published private(set) var connecting = false
    @Published private(set) var server: ServerStatus?
    @Published private(set) var user: User?

    private var serverCancellable: AnyCancellable?

    @MainActor
    var isAdmin: Bool {
        user?.admin ?? false
    }

    var url: URL? {
        repo?.url
    }

    init() {
        serverCancellable = settings.$server.sink { [weak self] in
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
    func addComment(
        to post: PostViewModel,
        content: String
    ) async throws -> CommentViewModel {
        guard let repo else { preconditionFailure("Missing repo") }

        let data = try await repo.addComment(post: post.id, content: content)
        let comment = state.comments.fetch(for: data)

        if let user = data.user {
            let user = state.users.fetch(for: user)
            user.commentCount += 1
            comment.user = user
        }

        return comment
    }

    @MainActor
    func addTag(name: String) async throws -> TagViewModel {
        guard let repo else { preconditionFailure("Missing repo") }

        let id = try await repo.addTag(name: name)
        let tag = state.tags.fetch(id: id)

        if let user {
            user.tagCount += 1
            tag.creator = user
        }

        return tag
    }

    func authenticate(_ login: Login) async throws {
        try await signOut(keepingPassword: true)

        let user = try await repo!.authenticate(login)
        settings.addAccount(id: user, email: login.email)
    }

    @MainActor
    func changeEmail(to email: String) async throws {
        guard let user else { return }

        try await repo!.setUserEmail(email)
        user.email = email
        settings.updateEmail(to: email)
    }

    func changePassword(to password: String) async throws {
        try await repo!.setUserPassword(password)
    }

    func connect(to url: URL) {
        settings.connect(to: url)
    }

    @MainActor
    private func connect(to server: Server) async {
        connecting = true
        defer { connecting = false }

        guard let repo = HTTPClient(
            baseURL: server.url,
            user: server.user,
            emails: settings.emails
        )
        else {
            self.server = .error(
                message: "Bad URL",
                detail: "The server URL (\(server.url)) is invalid."
            )
            return
        }

        if repo.url != self.repo?.url {
            do {
                let about = try await repo.about()
                self.server = .connected(about: about)
            }
            catch {
                self.server = .error(
                    message: "Connection Failure",
                    detail: error.localizedDescription
                )
                return
            }
        }

        if server.user != nil {
            do {
                let data = try await repo.getAuthenticatedUser()
                self.user = fetchUser(data)
            }
            catch {
                Logger.auth.error(
                    "Failed to get user information: \(error)"
                )
            }
        } else {
            user = nil
        }

        self.repo = repo
    }

    @MainActor
    func deleteAccount() async throws {
        if let user {
            try await repo!.deleteUser()
            user.delete()
            settings.removeAccount()
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
        return comments.map { data in
            let comment = state.comments.fetch(for: data)

            if let user = data.user {
                comment.user = state.users.fetch(for: user)
            }

            return comment
        }
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
    private func fetchUser(_ data: Minty.User) -> User {
        settings.updateAccount(using: data)

        let user = state.users.fetch(id: data.id)
        user.load(data)

        return user
    }

    @MainActor
    func findPosts(
        poster: User? = nil,
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
            poster: poster?.id,
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

        let results = try await repo.getTags(query: ProfileQuery(
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

    @MainActor
    func findUsers(
        _ name: String,
        from: Int = 0,
        size: Int
    ) async throws -> (hits: [User], total: Int) {
        guard let repo else { preconditionFailure("Expected repo") }

        let results = try await repo.getUsers(query: ProfileQuery(
            from: from,
            size: size,
            name: name
        ))

        return (
            hits: results.hits.map { state.users.fetch(for: $0) },
            total: results.total
        )
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

        user?.addDraft(draft)

        return draft
    }

    func register(_ info: SignUp) async throws {
        try await signOut(keepingPassword: true)

        let user = try await repo!.signUp(info, invitation: nil)
        settings.addAccount(id: user, email: info.email)
    }

    @MainActor
    func reply(to comment: CommentViewModel) async throws -> CommentViewModel {
        guard let repo else { preconditionFailure("Missing repo") }

        let data = try await repo.reply(
            to: comment.id,
            content: comment.draftReply
        )

        comment.draftReply.removeAll()

        let reply = state.comments.fetch(for: data)

        if let user = data.user {
            let user = state.users.fetch(for: user)
            user.commentCount += 1
            reply.user = user
        }

        return reply
    }

    @MainActor
    func signOut(keepingPassword: Bool) async throws {
        guard settings.server?.user != nil else { return }

        try await repo!.signOut(keepingPassword: keepingPassword)

        if !keepingPassword {
            settings.removeAccount()
        }
    }

    @MainActor
    func switchAccount(to user: UUID?) async throws {
        try await signOut(keepingPassword: true)

        if let user {
            try await repo!.authenticate(id: user)
        }

        settings.server?.user = user
    }

    @MainActor
    func user(id: UUID) async throws -> User {
        fetchUser(try await repo!.getUser(id: id))
    }
}

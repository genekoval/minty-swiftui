import Combine
import Minty
import Foundation

final class User: IdentifiableEntity, ObservableObject, StorableEntity {
    static let deleted = PassthroughSubject<ID, Never>()

    @Published var drafts: [PostViewModel] = []
    @Published var totalDrafts = 0
    @Published var draftsChecked = false

    @Published var name = ""
    @Published var draftName = ""

    @Published var aliases: [String] = []
    @Published var draftAlias = ""

    @Published var description = ""
    @Published var draftDescription = ""

    @Published var sources: [Source] = []
    @Published var draftSource = ""

    @Published var commentCount = 0
    @Published var postCount = 0
    @Published var tagCount = 0

    @Published var email = ""

    @Published private(set) var created = Date()
    @Published private(set) var admin = false

    private var cancellables = Set<AnyCancellable>()
    private weak var storage: UserState?

    init(id: UUID, storage: UserState?) {
        super.init(id: id, identifier: "user")

        self.storage = storage

        Post.published
            .sink { [weak self] post in self?.removeDraft(id: post.id) }
            .store(in: &cancellables)

        Post.deleted
            .sink { [weak self] id in self?.removeDraft(id: id) }
            .store(in: &cancellables)

        $name
            .sink { [weak self] in self?.draftName = $0 }
            .store(in: &cancellables)

        $description
            .sink { [weak self] in self?.draftDescription = $0 }
            .store(in: &cancellables)
    }

    deinit {
        if let storage {
            storage.remove(self)
        }
    }

    func addDraft(_ draft: PostViewModel) {
        drafts.insert(draft, at: 0)
        totalDrafts += 1
    }

    func delete() {
        Self.deleted.send(id)
    }

    func load(_ user: Minty.User) {
        name = user.profile.name
        aliases = user.profile.aliases
        description = user.profile.description
        sources = user.profile.sources
        created = user.profile.created
        email = user.email
        admin = user.admin
        postCount = user.postCount
        commentCount = user.commentCount
        tagCount = user.tagCount
    }

    func load(from preview: UserPreview) {
        name = preview.name
    }

    func load(names: ProfileName) {
        name = names.name
        aliases = names.aliases
    }

    func preview() -> UserPreview {
        UserPreview(id: id, name: name)
    }

    override func refresh() async throws {
        try await withRepo("fetch data") { repo in
            load(try await repo.getUser(id: id))
        }
    }

    private func removeDraft(id: Post.ID) {
        if drafts.remove(id: id) != nil {
            totalDrafts -= 1
        }
    }
}

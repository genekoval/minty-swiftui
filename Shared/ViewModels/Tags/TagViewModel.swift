import Combine
import Foundation
import Minty

final class TagViewModel: IdentifiableEntity, ObservableObject, StorableEntity {
    @Published var creator: User?

    @Published var draftAlias = ""
    @Published var draftDescription = ""
    @Published var draftName = ""
    @Published var draftSource = ""

    @Published var isEditing = false
    @Published var postCount = 0

    @Published private(set) var deleted = false
    @Published private(set) var name = ""
    @Published private(set) var aliases: [String] = []
    @Published private(set) var description = ""
    @Published private(set) var dateCreated = Date()
    @Published private(set) var sources: [Source] = []

    private var cancellables = Set<AnyCancellable>()
    private weak var storage: TagState?

    var draftAliasValid: Bool {
        !draftAlias.isEmpty
    }

    var draftNameValid: Bool {
        !draftName.isEmpty
    }

    var draftSourceValid: Bool {
        URL(string: draftSource) != nil
    }

    init(id: UUID, storage: TagState?) {
        super.init(id: id, identifier: "tag")

        self.storage = storage

        Tag.deleted
            .sink { [weak self] in self?.tagDeleted(id: $0) }
            .store(in: &cancellables)

        User.deleted
            .sink { [weak self] id in
                guard let self else { return }

                if id == creator?.id {
                    creator = nil
                }
            }
            .store(in: &cancellables)

        $name
            .sink { [weak self] in self?.draftName = $0 }
            .store(in: &cancellables)

        $description
            .sink { [weak self] in self?.draftDescription = $0 }
            .store(in: &cancellables)
    }

    deinit {
        if let storage = storage {
            storage.remove(self)
        }
    }

    func addAlias() async throws {
        guard draftAliasValid else { return }

        try await withRepo("add alias") { repo in
            refresh(names: try await repo.addTagAlias(
                tag: id,
                alias: draftAlias
            ))
        }

        draftAlias = ""
    }

    func addSource() async  throws {
        guard let url = URL(string: draftSource) else { return }

        try await withRepo("add source") { repo in
            let source = try await repo.addTagSource(tag: id, url: url)
            sources.append(source)
        }

        draftSource = ""
    }

    func commitDescription() async throws {
        try await withRepo("set description") { repo in
            description = try await repo.setTagDescription(
                id: id,
                description: draftDescription
            )
        }
    }

    func commitName() async throws {
        guard draftNameValid && draftName != name else { return }
        try await setName(name: draftName)
    }

    func delete() async throws {
        try await withRepo("delete tag") { repo in
            try await repo.deleteTag(id: id)
        }

        if let creator {
            creator.tagCount -= 1
        }

        Tag.deleted.send(id)
    }

    func deleteAlias(at index: Int) async throws {
        try await withRepo("delete alias") { repo in
            let alias = aliases.remove(at: index)
            let result = try await repo.deleteTagAlias(id: id, alias: alias)
            refresh(names: result)
        }
    }

    func deleteSource(at index: Int) async throws {
        let source = sources[index].id

        try await withRepo("delete source") { repo in
            try await repo.deleteTagSource(id: id, source: source)
        }

        sources.remove(at: index)
    }

    override func refresh() async throws {
        try await withRepo("fetch data") { repo in
            load(try await repo.getTag(id: id))
        }
    }

    private func load(_ tag: Tag) {
        if let creator = tag.creator {
            self.creator = app!.state.users.fetch(for: creator)
        }

        name = tag.profile.name
        aliases = tag.profile.aliases
        description = tag.profile.description
        dateCreated = tag.profile.created
        sources = tag.profile.sources
        postCount = tag.postCount
    }

    func load(from preview: TagPreview) {
        name = preview.name
    }

    private func refresh(names: ProfileName) {
        name = names.name
        aliases = names.aliases
    }

    private func setName(name: String) async throws {
        try await withRepo("set name") { repo in
            refresh(names: try await repo.setTagName(id: id, name: name))
        }
    }

    func swap(alias: String) async throws {
        try await setName(name: alias)
    }

    private func tagDeleted(id: UUID) {
        if id == self.id {
            deleted = true
        }
    }
}

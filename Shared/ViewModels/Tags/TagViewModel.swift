import Combine
import Foundation
import Minty

final class TagViewModel: IdentifiableEntity, ObservableObject, StorableEntity {
    @Published var draftAlias = ""
    @Published var draftDescription = ""
    @Published var draftName = ""
    @Published var draftSource = ""
    @Published var draftPost: PostViewModel?
    @Published var isEditing = false

    @Published private(set) var deleted = false
    @Published private(set) var name = ""
    @Published private(set) var aliases: [String] = []
    @Published private(set) var description: String?
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

        $name
            .sink { [weak self] in self?.draftName = $0 }
            .store(in: &cancellables)

        $description
            .sink { [weak self] in self?.draftDescription = $0 ?? "" }
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
        guard draftSourceValid else { return }

        try await withRepo("add source") { repo in
            sources.append(
                try await repo.addTagSource(tag: id, url: draftSource)
            )
        }

        draftSource = ""
    }

    func commitDescription() async throws {
        try await withRepo("set description") { repo in
            description = try await repo.set(
                tag: id,
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
            try await repo.delete(tag: id)
        }

        Tag.deleted.send(id)
    }

    func deleteAlias(at index: Int) async throws {
        try await withRepo("delete alias") { repo in
            let alias = aliases.remove(at: index)
            let result = try await repo.delete(tag: id, alias: alias)
            refresh(names: result)
        }
    }

    func deleteSource(at index: Int) async throws {
        let source = sources[index].id

        try await withRepo("delete source") { repo in
            try await repo.delete(tag: id, source: source)
        }

        sources.remove(at: index)
    }

    override func refresh() async throws {
        try await withRepo("fetch data") { repo in
            load(try await repo.get(tag: id))
        }
    }

    private func load(_ tag: Tag) {
        name = tag.name
        aliases = tag.aliases
        description = tag.description
        dateCreated = tag.dateCreated
        sources = tag.sources
    }

    func load(from preview: TagPreview) {
        name = preview.name
    }

    private func refresh(names: TagName) {
        name = names.name
        aliases = names.aliases
    }

    private func setName(name: String) async throws {
        try await withRepo("set name") { repo in
            refresh(names: try await repo.set(tag: id, name: name))
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

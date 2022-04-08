import Combine
import Foundation
import Minty

final class TagViewModel: IdentifiableEntity, ObservableObject {
    @Published var draftAlias = ""
    @Published var draftDescription = ""
    @Published var draftName = ""
    @Published var draftSource = ""

    @Published private(set) var deleted = false
    @Published private(set) var name = ""
    @Published private(set) var aliases: [String] = []
    @Published private(set) var description: String?
    @Published private(set) var dateCreated = Date()
    @Published private(set) var sources: [Source] = []
    @Published private(set) var postCount: Int = 0

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

    var preview: TagPreview {
        var tag = TagPreview()

        tag.id = id
        tag.name = name

        return tag
    }

    init(id: String, storage: TagState?) {
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

    func addAlias() throws {
        guard draftAliasValid else { return }

        try withRepo("add alias") { repo in
            refreshNames(
                names: try repo.addTagAlias(tagId: id, alias: draftAlias)
            )
        }

        draftAlias = ""
    }

    func addSource() throws {
        guard draftSourceValid else { return }

        try withRepo("add source") { repo in
            sources.append(try repo.addTagSource(tagId: id, url: draftSource))
        }

        draftSource = ""
    }

    func commitDescription() throws {
        try withRepo("set description") { repo in
            description = try repo.setTagDescription(
                tagId: id,
                description: draftDescription
            )
        }
    }

    func commitName() throws {
        guard draftNameValid && draftName != name else { return }
        try setName(name: draftName)
    }

    func delete() throws {
        try withRepo("delete tag") { repo in
            try repo.deleteTag(tagId: id)
        }

        Tag.deleted.send(id)
    }

    func deleteAlias(at index: Int) throws {
        try withRepo("delete alias") { repo in
            let alias = aliases.remove(at: index)
            let result = try repo.deleteTagAlias(tagId: id, alias: alias)
            refreshNames(names: result)
        }
    }

    func deleteSource(at index: Int) throws {
        try withRepo("delete source") { repo in
            let source = sources[index].id
            try repo.deleteTagSource(tagId: id, sourceId: source)
        }

        sources.remove(at: index)
    }

    override func refresh() throws {
        try withRepo("fetch data") { repo in
            load(from: try repo.getTag(tagId: id))
        }
    }

    private func load(from tag: Tag) {
        name = tag.name
        aliases = tag.aliases
        description = tag.description
        dateCreated = tag.dateCreated
        sources = tag.sources
        postCount = Int(tag.postCount)
    }

    func load(from preview: TagPreview) {
        name = preview.name
    }

    private func refreshNames(names: TagName) {
        name = names.name
        aliases = names.aliases
    }

    private func setName(name: String) throws {
        try withRepo("set name") { repo in
            refreshNames(names: try repo.setTagName(tagId: id, newName: name))
        }
    }

    func swap(alias: String) throws {
        try setName(name: alias)
    }

    private func tagDeleted(id: String) {
        if id == self.id {
            deleted = true
        }
    }
}

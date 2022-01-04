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

    init(id: String, repo: MintyRepo?) {
        super.init(id: id, identifier: "tag", repo: repo)

        Events
            .tagDeleted
            .sink { [weak self] in self?.tagDeleted(id: $0) }
            .store(in: &cancellables)

        $name
            .sink { [weak self] in self?.draftName = $0 }
            .store(in: &cancellables)

        $description
            .sink { [weak self] in self?.draftDescription = $0 ?? "" }
            .store(in: &cancellables)
    }

    func addAlias() {
        guard draftAliasValid else { return }

        withRepo("add alias") { repo in
            refreshNames(
                names: try repo.addTagAlias(tagId: id, alias: draftAlias)
            )
        }

        draftAlias = ""
    }

    func addSource() {
        guard draftSourceValid else { return }

        withRepo("add source") { repo in
            sources.append(try repo.addTagSource(tagId: id, url: draftSource))
        }

        draftSource = ""
    }

    func commitDescription() {
        withRepo("set description") { repo in
            description = try repo.setTagDescription(
                tagId: id,
                description: draftDescription
            )
        }
    }

    func commitName() {
        guard draftNameValid && draftName != name else { return }
        setName(name: draftName)
    }

    func delete() {
        withRepo("delete tag") { repo in
            try repo.deleteTag(tagId: id)
        }

        Events.tagDeleted.send(id)
    }

    func deleteAlias(at index: Int) {
        withRepo("delete alias") { repo in
            let alias = aliases.remove(at: index)
            let result = try repo.deleteTagAlias(tagId: id, alias: alias)
            refreshNames(names: result)
        }
    }

    func deleteSource(at index: Int) {
        withRepo("delete source") { repo in
            let source = sources[index].id
            try repo.deleteTagSource(tagId: id, sourceId: source)
        }

        sources.remove(at: index)
    }

    override func refresh() {
        withRepo("fetch data") { repo in
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

    private func refreshNames(names: TagName) {
        name = names.name
        aliases = names.aliases
    }

    private func setName(name: String) {
        withRepo("set name") { repo in
            refreshNames(names: try repo.setTagName(tagId: id, newName: name))
        }
    }

    func swap(alias: String) {
        setName(name: alias)
    }

    private func tagDeleted(id: String) {
        if id == self.id {
            deleted = true
        }
    }
}

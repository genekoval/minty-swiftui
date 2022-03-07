import Minty

class RemoteEntity {
    var repo: MintyRepo?

    private let identifier: String
    private var initialLoad = false

    init(identifier: String) {
        self.identifier = identifier
    }

    final func withRepo(
        _ description: String,
        action: (MintyRepo) throws -> Void
    ) throws {
        guard let repo = repo else { return }

        let id = "(\(identifier))"
        defaultLog.debug("\(id): \(description)")

        try action(repo)
    }

    final func load(repo: MintyRepo?) throws {
        self.repo = repo

        if !initialLoad {
            try refresh()
            initialLoad = true
        }
    }

    func refresh() throws { }
}

class IdentifiableEntity: RemoteEntity, Identifiable {
    let id: String

    init(id: String, identifier: String) {
        self.id = id
        super.init(identifier: "\(identifier) '\(id)'")
    }
}

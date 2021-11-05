import Minty

class RemoteEntity {
    let repo: MintyRepo?

    private let identifier: String

    init(identifier: String, repo: MintyRepo?) {
        self.identifier = identifier
        self.repo = repo
    }

    final func withRepo(
        _ description: String,
        action: (MintyRepo) throws -> Void
    ) {
        guard let repo = repo else { return }
        let failure = "Failed to \(description) for \(identifier)"

        do {
            try action(repo)
        }
        catch MintyError.unspecified(let message) {
            fatalError("\(failure): \(message)")
        }
        catch {
            fatalError("\(failure): \(error)")
        }
    }
}

class IdentifiableEntity: RemoteEntity, Identifiable {
    let id: String

    init(id: String, identifier: String, repo: MintyRepo?) {
        self.id = id

        super.init(identifier: "\(identifier) '\(id)'", repo: repo)

        refresh()
    }

    func refresh() { }
}

import Minty
import Foundation

class RemoteEntity {
    var repo: MintyRepo?

    private let identifier: String

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
        try refresh()
    }

    func refresh() throws { }
}

class IdentifiableEntity: RemoteEntity, Identifiable {
    let id: UUID

    init(id: UUID, identifier: String) {
        self.id = id
        super.init(identifier: "\(identifier) '\(id)'")
    }
}

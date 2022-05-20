import Minty
import Foundation

class RemoteEntity {
    var app: DataSource?

    private let identifier: String

    init(identifier: String) {
        self.identifier = identifier
    }

    final func withRepo(
        _ description: String,
        action: (MintyRepo) throws -> Void
    ) throws {
        guard let repo = app?.repo else { return }

        let id = "(\(identifier))"
        defaultLog.debug("\(id): \(description)")

        try action(repo)
    }

    final func load(app: DataSource) throws {
        self.app = app
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

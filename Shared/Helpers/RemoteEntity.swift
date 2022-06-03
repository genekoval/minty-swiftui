import Minty
import Foundation

@MainActor
class RemoteEntity {
    var app: DataSource?

    private let identifier: String

    init(identifier: String) {
        self.identifier = identifier
    }

    final func withRepo(
        _ description: String,
        action: (MintyRepo) async throws -> Void
    ) async throws {
        guard let repo = app?.repo else { return }

        let id = "(\(identifier))"
        defaultLog.debug("\(id): \(description)")

        try await action(repo)
    }

    final func load(app: DataSource) async throws {
        self.app = app
        try await refresh()
    }

    func refresh() async throws { }
}

class IdentifiableEntity: RemoteEntity, Identifiable {
    let id: UUID

    init(id: UUID, identifier: String) {
        self.id = id
        super.init(identifier: "\(identifier) '\(id)'")
    }
}

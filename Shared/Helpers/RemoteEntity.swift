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
        action: @escaping (MintyRepo) async throws -> Void
    ) async throws {
        try await app?.withRepo { [self] repo in
            let id = "(\(identifier)): \(description)"
            defaultLog.debug("Starting \(id)")

            do {
                try await action(repo)
                defaultLog.debug("Success  \(id)")
            }
            catch {
                defaultLog.debug("Failure  \(id)")
                throw error
            }
        }
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

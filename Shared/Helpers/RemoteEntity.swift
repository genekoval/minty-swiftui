import Combine
import Minty

class RemoteEntity {
    private var cancellable: AnyCancellable?
    private let identifier: String
    var repo: MintyRepo? {
        didSet {
            if oldValue == nil { refresh() }
        }
    }

    init(identifier: String) {
        self.identifier = identifier
    }

    func refresh() { }

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

    init(id: String, identifier: String) {
        self.id = id
        super.init(identifier: "\(identifier) '\(id)'")
    }
}

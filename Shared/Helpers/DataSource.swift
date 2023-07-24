import Combine
import Foundation
import Minty

enum ServerStatus {
    case connected(version: String)
    case error(message: String, detail: String)
}

final class DataSource: ObservableObject {
    typealias Connect = (Server) async throws -> MintyRepo

    let state = AppState()
    var onFailedConnection: ((Error) -> Void)?

    @Published var repo: MintyRepo?
    @Published private(set) var connecting = false
    @Published private(set) var server: ServerStatus?

    private var cancellable: AnyCancellable?
    private let connectAction: Connect?

    init(connect: @escaping Connect) {
        connectAction = connect
    }

    func addTag(name: String) async throws -> TagViewModel {
        guard let repo else { preconditionFailure("Missing repo") }

        let id = try await repo.addTag(name: name)
        return state.tags.fetch(id: id)
    }

    @MainActor
    private func connect(server: Server) async {
        guard let connect = connectAction else { return }

        connecting = true

        do {
            let repo = try await connect(server)

            self.repo = repo
            self.server = .connected(version: repo.version)
        }
        catch {
            self.server = .error(
                message: "Connection Failure",
                detail: error.localizedDescription
            )
            onFailedConnection?(MintyError.unspecified(
                message: "Couldn't connect to the server."
            ))
        }

        connecting = false
    }

    func observe(server: Published<Server?>.Publisher) {
        cancellable = server.sink { [weak self] in
            guard
                let self = self,
                let server = $0
            else {
                self?.repo = nil
                self?.server = nil

                return
            }

            Task {
                await self.connect(server: server)
            }
        }
    }
}

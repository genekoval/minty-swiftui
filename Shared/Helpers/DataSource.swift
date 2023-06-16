import Combine
import Foundation
import Minty
import Zipline

enum ServerStatus {
    case connected(metadata: ServerMetadata)
    case error(message: String, detail: String)
}

final class DataSource: ObservableObject {
    typealias Connect = (Server) async throws -> (MintyRepo, ServerMetadata)

    let state = AppState()
    var onFailedConnection: ((Error) -> Void)?

    @Published var repo: MintyRepo?
    @Published private(set) var server: ServerStatus?

    private var cancellable: AnyCancellable?
    private let connectAction: Connect?

    init(connect: @escaping Connect) {
        connectAction = connect
    }

    @MainActor
    private func connect(server: Server) async {
        guard let connect = connectAction else { return }

        do {
            let (repo, metadata) = try await connect(server)
            self.repo = repo
            self.server = .connected(metadata: metadata)
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

    func withRepo(
        _ action: (MintyRepo) async throws -> Void
    ) async throws {
        try await action(repo!)
    }
}

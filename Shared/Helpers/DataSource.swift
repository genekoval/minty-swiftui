import Combine
import Minty

final class DataSource: ObservableObject {
    @Published var repo: MintyRepo?

    private var cancellable: AnyCancellable?

    init(repo: MintyRepo? = nil) {
        self.repo = repo
    }

    func observe(server: Published<Server?>.Publisher) {
        cancellable = server.sink { [weak self] in
            if let value = $0 {
                self?.connect(server: value)
            }
        }
    }

    private func connect(server: Server) {
        repo = try? ZiplineClient(host: server.host, port: server.port)
    }
}

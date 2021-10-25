import Combine
import Minty

final class DataSource: ObservableObject {
    typealias Connect = (Server) -> MintyRepo?

    @Published var repo: MintyRepo?

    private var cancellable: AnyCancellable?
    private let connect: Connect?

    init(connect: Connect? = nil, repo: MintyRepo? = nil) {
        self.connect = connect
        self.repo = repo
    }

    func observe(server: Published<Server?>.Publisher) {
        cancellable = server.sink { [weak self] in
            if let value = $0 {
                self?.repo = self?.connect?(value)
            }
            else {
                self?.repo = nil
            }
        }
    }
}

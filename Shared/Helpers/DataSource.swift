import Combine
import Foundation
import Minty

final class DataSource: ObservableObject {
    typealias Connect = (Server) -> MintyRepo?

    let state = AppState()

    @Published var repo: MintyRepo?

    private var cancellable: AnyCancellable?
    private let connect: Connect?

    init(connect: Connect? = nil, repo: MintyRepo? = nil) {
        self.connect = connect
        self.repo = repo
    }

    func observe(server: Published<Server?>.Publisher) {
        cancellable = server.sink { [weak self] in
            guard let self = self else { return }

            guard
                let value = $0,
                let repo = self.connect?(value)
            else {
                self.repo = nil
                return
            }

            self.repo = repo
        }
    }
}

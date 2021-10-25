import Foundation
import Minty

struct ObjectFile: Identifiable {
    let id: String
    let size: Int64
}

class ObjectSource: ObservableObject {
    @Published var cachedObjects: [ObjectFile] = []

    weak var dataSource: DataSource?

    final var repo: MintyRepo? { dataSource?.repo }

    final var cacheSize: Int64 {
        cachedObjects.reduce(0) { $0 + $1.size }
    }

    func clearCache() { cachedObjects.removeAll() }

    func data(for id: String) async -> Data { Data() }

    func remove(at index: Int) {
        cachedObjects.remove(at: index)
    }
}

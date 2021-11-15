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

    func makeUploadable(text: String) -> Uploadable {
        if UUID(uuidString: text) != nil {
            return .existingObject(text)
        }
        else {
            return .url(text)
        }
    }

    func remove(at index: Int) {
        cachedObjects.remove(at: index)
    }

    final func url(for objectId: String?) -> URL? {
        guard let id = objectId else { return nil }
        return url(for: id)
     }

    func url(for objectId: String) -> URL? { nil }
}

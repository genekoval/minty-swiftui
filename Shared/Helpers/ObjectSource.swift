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

    func clearCache() throws { cachedObjects.removeAll() }

    func makeUploadable(text: String) throws -> Uploadable {
        if UUID(uuidString: text) == nil {
            return .url(text)
        }

        guard let repo = repo else {
            throw MintyError.unspecified(
                message: "Cannot get object: repo missing"
            )
        }

        let object = try repo.getObject(objectId: text)

        var preview = ObjectPreview()
        preview.id = object.id
        preview.previewId = object.previewId
        preview.mimeType = object.mimeType

        return .existingObject(preview)
    }

    func refresh() throws { }

    func remove(at index: Int) throws {
        cachedObjects.remove(at: index)
    }

    func upload(url: URL) async throws -> ObjectPreview? { nil }

    final func url(for objectId: String?) throws -> URL? {
        guard let id = objectId else { return nil }
        return try url(for: id)
    }

    func url(for objectId: String) throws -> URL? { nil }
}

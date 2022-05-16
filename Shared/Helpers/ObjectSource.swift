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
        guard let id = UUID(uuidString: text) else {
            return .url(text)
        }

        guard let repo = repo else {
            throw MintyError.unspecified(
                message: "Cannot get object: repo missing"
            )
        }

        let object = try repo.getObject(objectId: id)

        var preview = ObjectPreview()
        preview.id = object.id
        preview.previewId = object.previewId
        preview.type = object.type
        preview.subtype = object.subtype

        return .existingObject(preview)
    }

    func refresh() throws {
        cachedObjects.sort(by: { $0.size > $1.size })
    }

    func remove(at index: Int) throws {
        cachedObjects.remove(at: index)
    }

    func upload(url: URL) async throws -> ObjectPreview? { nil }

    final func url(for objectId: UUID?) throws -> URL? {
        guard let id = objectId else { return nil }
        return try url(for: id)
    }

    func url(for objectId: UUID) throws -> URL? { nil }
}

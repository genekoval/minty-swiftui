import Foundation
import Minty

struct ObjectFile: Identifiable {
    let id: String
    let size: Int64
}

class ObjectSource: ObservableObject {
    @Published var cachedObjects: [ObjectFile] = []

    private var modified: Date

    private var refreshed: Date

    weak var dataSource: DataSource?

    final var needsRefresh: Bool {
        modified >= refreshed
    }

    final var cacheSize: Int64 {
        cachedObjects.reduce(0) { $0 + $1.size }
    }

    init() {
        let now = Date()
        modified = now
        refreshed = now
    }

    func clearCache() throws { cachedObjects.removeAll() }

    func makeUploadable(text: String) async throws -> Uploadable {
        guard let id = UUID(uuidString: text) else {
            return .url(text)
        }

        guard let repo = dataSource?.repo else {
            throw MintyError.unspecified(
                message: "Cannot get object: repo missing"
            )
        }

        let object = try await repo.getObject(objectId: id)

        var preview = ObjectPreview()
        preview.id = object.id
        preview.previewId = object.previewId
        preview.type = object.type
        preview.subtype = object.subtype

        return .existingObject(preview)
    }

    func refresh() async {
        defaultLog.debug("Refreshing cache list")
        refreshed = Date()
    }

    func remove(at index: Int) throws {
        cachedObjects.remove(at: index)
    }

    func updateModified() {
        modified = Date()
    }

    func upload(url: URL) async throws -> ObjectPreview? { nil }

    final func url(for objectId: UUID?) async throws -> URL? {
        guard let id = objectId else { return nil }
        return try await url(for: id)
    }

    func url(for objectId: UUID) async throws -> URL? { nil }
}

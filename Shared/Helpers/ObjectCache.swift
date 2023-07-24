import Foundation
import Minty

private let fileManager = FileManager.default

private func createCacheDirectory(name: String) -> URL {
    do {
        let directory = try fileManager.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent(name, isDirectory: true)

        try fileManager.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )

        return directory
    }
    catch {
        fatalError("Failed to create '\(name)' cache directory: \(error)")
    }
}

private func getFileSize(for url: URL) -> Int64 {
    do {
        let attributes = try fileManager.attributesOfItem(atPath: url.path)
        return attributes[.size] as! Int64
    }
    catch {
        let log = "Failed to get attributes for file: '\(url.path)': \(error)"
        defaultLog.error("\(log)")
    }

    return 0
}

final class ObjectCache: ObjectSource {
    private static func createCacheDirectory() -> URL {
        MintyUI.createCacheDirectory(name: "Objects")
    }

    private let objectsDirectory: URL = ObjectCache.createCacheDirectory()

    override func clearCache() throws {
        do {
            try fileManager.removeItem(at: objectsDirectory)
        }
        catch {
            let message = "Failed to remove object cache directory"
            let logMessage = "\(message): \(error)"

            defaultLog.error("\(logMessage)")
            throw MintyError.unspecified(message: message)
        }

        _ = ObjectCache.createCacheDirectory()
        try super.clearCache()
    }

    private func getObjectURL(id: UUID) -> URL {
        objectsDirectory.appendingPathComponent(id.uuidString)
    }

    override func refresh() async {
        await super.refresh()

        let objects = await scanDirectory().sorted(by: { $0.size > $1.size })

        await MainActor.run {
            cachedObjects = objects
        }
    }

    override func remove(at index: Int) throws {
        let file = cachedObjects[index]
        let url = objectsDirectory.appendingPathComponent(file.id)

        do {
            try fileManager.removeItem(at: url)
        }
        catch {
            let message = "Failed to delete cached file"
            let log = "\(message) '\(file.id)': \(error)"

            defaultLog.error("\(log)")
            throw MintyError.unspecified(message: message)
        }

        try super.remove(at: index)
    }

    private func scanDirectory() async -> [ObjectFile] {
        return await Task {
            do {
                return try fileManager
                    .contentsOfDirectory(
                        at: objectsDirectory,
                        includingPropertiesForKeys: nil
                    )
                    .map { ObjectFile(
                        id: $0.lastPathComponent,
                        size: getFileSize(for: $0)
                    )}
            }
            catch {
                let message = "Failed to read cache directory contents"
                let log = "\(message): \(error)"

                defaultLog.error("\(log)")
            }

            return []
        }.value
    }

    override func upload(url: URL) async throws -> ObjectPreview? {
        guard let repo = dataSource?.repo else { return nil }
        return try await repo.addObject(file: url)
    }

    override func url(for objectId: UUID) async throws -> URL? {
        let url = getObjectURL(id: objectId)

        if fileManager.fileExists(atPath: url.path) {
            return url
        }

        guard let repo = dataSource?.repo else { return nil }
        try await repo.download(object: objectId, destination: url)

        updateModified()

        return url
    }
}

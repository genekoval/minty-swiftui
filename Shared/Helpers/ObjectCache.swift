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

    private func getObjectURL(id: String) -> URL {
        objectsDirectory.appendingPathComponent(id)
    }

    override func refresh() throws {
        do {
            cachedObjects = try fileManager
                .contentsOfDirectory(
                    at: objectsDirectory,
                    includingPropertiesForKeys: nil
                )
                .map { ObjectFile(
                    id: $0.lastPathComponent,
                    size: getFileSize(for: $0)
                )}

            try super.refresh()
        }
        catch {
            let message = "Failed to get cache directory contents"
            let log = "\(message): \(error)"

            defaultLog.error("\(log)")
            throw MintyError.unspecified(message: message)
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

    override func upload(url: URL) async throws -> ObjectPreview? {
        guard let repo = repo else { return nil }

        let (data, _) = try await URLSession.shared.data(from: url)
        return try repo.addObjectData(count: data.count, data: { writer in
            writer.write(data: data)
        })
    }

    override func url(for objectId: String) throws -> URL? {
        let url = getObjectURL(id: objectId)

        if fileManager.fileExists(atPath: url.path) {
            return url
        }

        guard let repo = repo else { return nil }

        if !fileManager.createFile(atPath: url.path, contents: nil) {
            defaultLog.error("Failed to create file at path: \(url.path)")
            throw MintyError.unspecified(message: "Failed to create cache file")
        }

        do {
            let handle = try FileHandle(forWritingTo: url)

            try repo.getObjectData(objectId: objectId) { data in
                try handle.write(contentsOf: data)
            }
        }
        catch {
            let message = "Failed to download object"
            let log = "\(message): \(error)"

            defaultLog.error("\(log)")
            throw MintyError.unspecified(message: message)
        }

        do {
            try refresh()
        }
        catch {
            let log = "Failed to refresh cache list after download: \(error)"
            defaultLog.error("\(log)")
        }

        return url
    }
}

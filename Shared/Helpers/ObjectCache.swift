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
        fatalError("Failed to create '\(name)' cache directory:\n\(error)")
    }
}

private func getFileSize(for url: URL) -> Int64 {
    do {
        let attributes = try fileManager.attributesOfItem(atPath: url.path)
        return attributes[.size] as! Int64
    }
    catch {
        fatalError("Failed to attributes for file '\(url.path)':\n\(error)")
    }

}

final class ObjectCache: ObjectSource {
    private static func createCacheDirectory() -> URL {
        MintyUI.createCacheDirectory(name: "Objects")
    }

    private let objectsDirectory: URL = ObjectCache.createCacheDirectory()

    override init() {
        super.init()
        refresh()
    }

    override func clearCache() {
        do {
            try fileManager.removeItem(at: objectsDirectory)
        }
        catch {
            fatalError("Failed to remove object cache directory:\n\(error)")
        }

        _ = ObjectCache.createCacheDirectory()
        super.clearCache()
    }

    private func getObjectURL(id: String) -> URL {
        objectsDirectory.appendingPathComponent(id)
    }

    private func refresh() {
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
        }
        catch {
            fatalError("Failed to get cache directory contents:\n\(error)")
        }
    }

    override func remove(at index: Int) {
        let file = cachedObjects[index]
        let url = objectsDirectory.appendingPathComponent(file.id)

        do {
            try fileManager.removeItem(at: url)
        }
        catch {
            fatalError("Failed to delete cached file '\(file.id)':\n\(error)")
        }

        super.remove(at: index)
    }

    override func url(for objectId: String) -> URL? {
        let url = getObjectURL(id: objectId)

        if fileManager.fileExists(atPath: url.path) {
            return url
        }

        guard let repo = repo else { return nil }

        if !fileManager.createFile(atPath: url.path, contents: nil) {
            return nil
        }

        do {
            let handle = try FileHandle(forWritingTo: url)

            try repo.getObjectData(objectId: objectId) { data in
                do {
                    try handle.write(contentsOf: data)
                }
                catch {
                    fatalError("Failed to write data to object file:\n\(error)")
                }
            }

            refresh()
            return url
        }
        catch {
            fatalError("Failed to download object:\n\(error)")
        }
    }
}

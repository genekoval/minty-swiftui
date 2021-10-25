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

    override func data(for objectId: String) async -> Data {
        let url = getObjectURL(id: objectId)

        if !fileManager.fileExists(atPath: url.path) {
            if !downloadObject(id: objectId, dest: url) {
                return Data()
            }
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        }
        catch {
            fatalError(
                "Failed to read cached object file '\(url.path)':\n\(error)"
            )
        }
    }

    private func downloadObject(id: String, dest: URL) -> Bool {
        guard let repo = repo else { return false }

        if !fileManager.createFile(atPath: dest.path, contents: nil) {
            return false
        }

        do {
            let handle = try FileHandle(forWritingTo: dest)

            try repo.getObjectData(objectId: id) { data in
                do {
                    try handle.write(contentsOf: data)
                }
                catch {
                    fatalError("Failed to write data to object file:\n\(error)")
                }
            }
        }
        catch {
            fatalError("Failed to download object:\n\(error)")
        }

        refresh()
        return true
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
}

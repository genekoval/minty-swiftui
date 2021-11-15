import Foundation
import Minty

private func uploadURL(_ url: String, repo: MintyRepo) -> [String] {
    do {
        return try repo.addObjectsUrl(url: url)
    }
    catch {
        fatalError("Failed to extract objects from URL '\(url)': \(error)")
    }
}

enum Uploadable: Identifiable {
    case existingObject(String)
    case url(String)

    var id: String {
        switch self {
        case .existingObject(let objectId):
            return objectId
        case .url(let urlString):
            return urlString
        }
    }

    func upload(objects: inout [String], repo: MintyRepo) {
        switch self {
        case .existingObject(let objectId):
            objects.append(objectId)
        case .url(let urlString):
            objects.append(contentsOf: uploadURL(urlString, repo: repo))
        }
    }
}

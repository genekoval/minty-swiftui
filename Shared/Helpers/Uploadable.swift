import Foundation
import Minty
import SwiftUI

private func uploadFile(
    src url: URL,
    dest: inout [String],
    source: ObjectSource
) async {
    if let id = await source.upload(url: url) {
        dest.append(id)
    }
}

private func uploadSecureFile(
    src url: URL,
    dest: inout [String],
    source: ObjectSource
) async {
    guard url.startAccessingSecurityScopedResource() else {
        fatalError("Failed to obtain access to resource: \(url)")
    }

    defer {
        url.stopAccessingSecurityScopedResource()
    }

    await uploadFile(src: url, dest: &dest, source: source)
}

private func uploadURL(_ url: String, source: ObjectSource) -> [String] {
    guard let repo = source.repo else { return [] }

    do {
        return try repo.addObjectsUrl(url: url)
    }
    catch {
        fatalError("Failed to extract objects from URL '\(url)': \(error)")
    }
}

enum Uploadable: Identifiable {
    case existingObject(String)
    case file(URL)
    case image(UIImage, URL)
    case url(String)

    var id: String {
        switch self {
        case .existingObject(let objectId):
            return objectId
        case .file(let url):
            return url.path
        case .image(_, let url):
            return url.path
        case .url(let urlString):
            return urlString
        }
    }

    func upload(objects: inout [String], source: ObjectSource) async {
        switch self {
        case .existingObject(let objectId):
            objects.append(objectId)
        case .file(let url):
            await uploadSecureFile(src: url, dest: &objects, source: source)
        case .image(_, let url):
            await uploadFile(src: url, dest: &objects, source: source)
        case .url(let urlString):
            objects.append(contentsOf: uploadURL(urlString, source: source))
        }
    }

    @ViewBuilder
    func view() -> some View {
        switch self {
        case .existingObject(let objectId):
            Label(objectId, systemImage: "doc.fill")
        case .file(let url):
            Label(url.lastPathComponent, systemImage: "folder.fill")
        case .image(let image, _):
            HStack {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80)
                Text("From Photos")
            }
        case .url(let urlString):
            Label(urlString, systemImage: "network")
        }
    }
}
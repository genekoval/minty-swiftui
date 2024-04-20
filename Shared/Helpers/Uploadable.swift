import os
import Foundation
import Minty
import SwiftUI

enum UploadError: Error {
    case badURL
    case badResponse(statusCode: Int)
    case unsupportedRequest(scheme: String?)
}

private func uploadFile(
    src url: URL,
    source: ObjectSource
) async throws -> ObjectPreview? {
    try await source.upload(url: url)
}

private func uploadSecureFile(
    src url: URL,
    source: ObjectSource
) async throws -> ObjectPreview? {
    guard url.startAccessingSecurityScopedResource() else {
        throw MintyError.other(
            message: "Failed to obtain access to resource: \(url)"
        )
    }

    defer {
        url.stopAccessingSecurityScopedResource()
    }

    return try await uploadFile(src: url, source: source)
}

private func uploadURL(
    _ url: String,
    source: ObjectSource
) async throws -> ObjectPreview {
    guard let repo = source.dataSource?.repo else {
        preconditionFailure("Missing repo")
    }
    guard let url = URL(string: url) else { throw UploadError.badURL }

    let request = URLRequest(url: url)
    let (location, response) =
        try await URLSession.shared.download(for: request)

    defer {
        do {
            try FileManager.default.removeItem(at: location)
        }
        catch {
            Logger.ui.error("Failed to remove file at \"\(location)\"")
        }
    }

    guard let response = response as? HTTPURLResponse else {
        throw UploadError.unsupportedRequest(scheme: url.scheme)
    }

    let status = response.statusCode
    Logger.ui.debug("\(status) GET \(url)")
    guard (200...299).contains(status) else {
        throw UploadError.badResponse(statusCode: status)
    }

    return try await repo.addObject(file: location)
}

enum Uploadable: Identifiable {
    case existingObject(ObjectPreview)
    case file(URL)
    case image(UIImage, URL)
    case url(String)

    var id: String {
        switch self {
        case .existingObject(let object):
            return object.id.uuidString
        case .file(let url):
            return url.path
        case .image(_, let url):
            return url.path
        case .url(let urlString):
            return urlString
        }
    }

    func upload(
        objects: inout [ObjectPreview],
        source: ObjectSource
    ) async throws {
        switch self {
        case .existingObject(let object):
            objects.append(object)
        case .file(let url):
            if let object =
                try await uploadSecureFile(src: url, source: source)
            {
                objects.append(object)
            }
        case .image(_, let url):
            if let object = try await uploadFile(src: url, source: source) {
                objects.append(object)
            }
        case .url(let urlString):
            objects.append(try await uploadURL(urlString, source: source))
        }
    }

    @ViewBuilder
    func view() -> some View {
        switch self {
        case .existingObject(let object):
            HStack {
                PreviewImage(object: object)
                Text(object.id.uuidString)
            }
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

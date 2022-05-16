import Foundation
import Minty

private let resources = [
    "fb4c62cf-fc57-415e-8651-1d2f25483221": "unsplash.png",
    "8b9f71fd-d344-4098-9f8c-8165b7d3c783": "wikipedia.png"
]

final class PreviewObjectSource: ObjectSource {
     init(objects: [ObjectFile]) {
        super.init()
        cachedObjects = objects
    }

    override func makeUploadable(text: String) -> Uploadable {
        guard let id = UUID(uuidString: text) else {
            return .url(text)
        }

        return .existingObject(ObjectPreview.preview(id: id))
    }

    override func url(for objectId: UUID) -> URL? {
        let resource = resources[objectId.uuidString]
        return Bundle.main.url(forResource: resource, withExtension: nil)
    }
}

extension ObjectSource {
    static let preview: ObjectSource = PreviewObjectSource(objects: [
        ObjectFile(
            id: "ce5cb5a4-4ea3-4421-bbff-9d0f6d22f0eb",
            size: 1024
        ),
        ObjectFile(
            id: "3274623b-b0e1-4bb5-95fa-602d1f7fcecb",
            size: 8
        ),
        ObjectFile(
            id: "4643bdac-2545-41e2-953c-76a1df21308f",
            size: 2872364
        ),
        ObjectFile(
            id: "8130ea46-f0f9-40a8-8e59-ba9ef6e79ad1",
            size: 28347234
        ),
        ObjectFile(
            id: "9cff197e-d453-4d26-83e9-cce0a4fb8837",
            size: 32423
        )
    ])
}

import Foundation
import Minty

final class PreviewObjectSource: ObjectSource {
     init(objects: [ObjectFile]) {
        super.init()
        cachedObjects = objects
    }

    override func data(for id: String) async -> Data {
        guard let url = Bundle.main.url(
            forResource: id,
            withExtension: nil
        ) else {
            fatalError("Object not found: \(id)")
        }

        do {
            return try Data(contentsOf: url)
        }
        catch {
            fatalError("Failed to read object data for: \(id)")
        }
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

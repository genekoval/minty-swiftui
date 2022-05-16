import Foundation
import Minty

private let sizeFormatter: ByteCountFormatter = {
    let formatter = ByteCountFormatter()

    return formatter
}()

struct PreviewObject {
    static let empty =
        UUID(uuidString: "76698f22-6169-4327-a7e4-453f509f6d2e")!
    static let sandDune =
        UUID(uuidString: "ada13eae-11c7-4024-9583-83a3560097fc")!
    static let sandDunePreview =
        UUID(uuidString: "d7ea2075-ae8c-4c6d-83ea-814a515539e2")!
}

private final class PreviewData {
    private var objects: [UUID: Object] = [:]
    private var previews: [UUID: ObjectPreview] = [:]

    init() {
        addObject(
            id: PreviewObject.sandDune,
            hash: "1231a42cd48638c8cf80eff03ee9a3da91ff4a3d7136d8883a35f329c7a2e7c0",
            size: 1_140_573,
            type: "image",
            subtype: "jpeg",
            dateAdded: "2020-12-29 12:00:00.000-04",
            previewId: PreviewObject.sandDunePreview,
            source: "sand dune"
        )

        addObject(
            id: PreviewObject.empty,
            hash: "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
            size: 0,
            type: "inode",
            subtype: "x-empty",
            dateAdded: "2000-04-01 16:00:00.000-04",
            previewId: nil
        )
    }

    private func addObject(
        id: UUID,
        hash: String,
        size: UInt64,
        type: String,
        subtype: String,
        dateAdded: String? = nil,
        previewId: UUID? = nil,
        source: String? = nil
    ) {
        var dataSize = DataSize()
        dataSize.bytes = size
        dataSize.formatted = sizeFormatter.string(fromByteCount: Int64(size))

        var object = Object()

        object.id = id
        object.hash = hash
        object.size = dataSize
        object.type = type
        object.subtype = subtype
        if let date = dateAdded { object.dateAdded = Date(from: date) }
        object.previewId = previewId
        if let source = source { object.source = Source.preview(id: source) }

        var preview = ObjectPreview()

        preview.id = object.id
        preview.previewId = object.previewId
        preview.type = object.type
        preview.subtype = object.subtype

        objects[id] = object
        previews[id] = preview
    }

    func get(object id: UUID) -> Object {
        guard var object = objects[id] else {
            fatalError("Object with ID (\(id)) does not exist")
        }

        let previews = PostPreview.preview(query: PostQuery())

        for preview in previews {
            let post = Post.preview(id: preview.id)

            if post.objects.contains(where: { $0.id == id }) {
                object.posts.append(preview)
            }
        }

        return object
    }

    func get(preview id: UUID) -> ObjectPreview {
        if let preview = data.previews[id] { return preview }
        fatalError("Object Preview with ID (\(id)) does not exist")
    }
}

private let data = PreviewData()

extension Object {
    static func preview(id: UUID) -> Object {
        data.get(object: id)
    }
}

extension ObjectPreview {
    static func preview(id: UUID) -> ObjectPreview {
        data.get(preview: id)
    }
}

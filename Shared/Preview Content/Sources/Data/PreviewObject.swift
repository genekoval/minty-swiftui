import Foundation
import Minty

private let sizeFormatter: ByteCountFormatter = {
    let formatter = ByteCountFormatter()

    return formatter
}()

struct PreviewObject {
    static let empty =
        UUID(uuidString: "76698F22-6169-4327-A7E4-453F509F6D2E")!

    static let sandDune =
        UUID(uuidString: "ADA13EAE-11C7-4024-9583-83A3560097FC")!

    static let sandDunePreview =
        UUID(uuidString: "D7EA2075-AE8C-4C6D-83EA-814A515539E2")!

    static let unsplash =
        UUID(uuidString: "FB4C62CF-FC57-415E-8651-1D2F25483221")!

    static let wikipedia =
        UUID(uuidString: "8B9F71FD-D344-4098-9F8C-8165B7D3C783")!
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

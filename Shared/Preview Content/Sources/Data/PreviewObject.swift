import Foundation
import Minty

private let sizeFormatter: ByteCountFormatter = {
    let formatter = ByteCountFormatter()

    return formatter
}()

private final class PreviewData {
    private var objects: [String: Object] = [:]
    private var previews: [String: ObjectPreview] = [:]

    init() {
        addObject(
            id: "sand dune.jpg",
            hash: "1231a42cd48638c8cf80eff03ee9a3da91ff4a3d7136d8883a35f329c7a2e7c0",
            size: 1_140_573,
            type: "image",
            subtype: "jpeg",
            dateAdded: "2020-12-29 12:00:00.000-04",
            previewId: "sand dune (preview).png",
            source: "sand dune"
        )

        addObject(
            id: "empty",
            hash: "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
            size: 0,
            type: "inode",
            subtype: "x-empty",
            dateAdded: "2000-04-01 16:00:00.000-04",
            previewId: nil
        )
    }

    private func addObject(
        id: String,
        hash: String,
        size: UInt64,
        type: String,
        subtype: String,
        dateAdded: String? = nil,
        previewId: String? = nil,
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

    func get(object id: String) -> Object {
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

    func get(preview id: String) -> ObjectPreview {
        if let preview = data.previews[id] { return preview }
        fatalError("Object Preview with ID (\(id)) does not exist")
    }
}

private let data = PreviewData()

extension Object {
    static func preview(id: String) -> Object {
        data.get(object: id)
    }
}

extension ObjectPreview {
    static func preview(id: String) -> ObjectPreview {
        data.get(preview: id)
    }
}

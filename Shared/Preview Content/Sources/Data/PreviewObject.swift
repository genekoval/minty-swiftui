import Foundation
import Minty

private let sizeFormatter: ByteCountFormatter = {
    let formatter = ByteCountFormatter()

    return formatter
}()

private final class PreviewData {
    private(set) var objects: [String: Object] = [:]
    private(set) var previews: [String: ObjectPreview] = [:]

    init() {
        addObject(
            id: "sand dune.jpg",
            hash: "1231a42cd48638c8cf80eff03ee9a3da91ff4a3d7136d8883a35f329c7a2e7c0",
            size: 1_140_573,
            mimeType: "image/jpeg",
            dateAdded: "2020-12-29 12:00:00.000-04",
            previewId: "sand dune (preview).png",
            source: "sand dune"
        )
    }

    func addObject(
        id: String,
        hash: String,
        size: UInt64,
        mimeType: String,
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
        object.mimeType = mimeType
        if let date = dateAdded { object.dateAdded = Date(from: date) }
        object.previewId = previewId
        if let source = source { object.source = Source.preview(id: source) }

        var preview = ObjectPreview()

        preview.id = object.id
        preview.previewId = object.previewId
        preview.mimeType = object.mimeType

        objects[id] = object
        previews[id] = preview
    }
}

private let data = PreviewData()

extension Object {
    static func preview(id: String) -> Object {
        data.objects[id]!
    }
}

extension ObjectPreview {
    static func preview(id: String) -> ObjectPreview {
        data.previews[id]!
    }
}

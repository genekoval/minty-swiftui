import Minty

private let mediaTypes = [
    "audio",
    "video"
]

private let viewableTypes = [
    "image"
]

struct MimeType {
    let type: String
    let subtype: String

    init(_ mimeType: String) {
        let subsequences = mimeType.split(
            maxSplits: 2,
            whereSeparator: { $0 == "/" }
        )

        type = String(subsequences[0])
        subtype = String(subsequences[1])
    }
}

private func isMediaType(_ mimeType: MimeType) -> Bool {
    mediaTypes.contains(mimeType.type)
}

private func isViewableType(_ mimeType: MimeType) -> Bool {
    viewableTypes.contains(mimeType.type)
}

extension ObjectPreview {
    var isMedia: Bool {
        let mimeType = MimeType(self.mimeType)
        return isMediaType(mimeType)
    }

    var isViewable: Bool {
        let mimeType = MimeType(self.mimeType)
        return isViewableType(mimeType)
    }

    var type: String {
        MimeType(self.mimeType).type
    }

    var subtype: String {
        MimeType(self.mimeType).subtype
    }
}
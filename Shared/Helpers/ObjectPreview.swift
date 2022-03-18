import Minty

private let mediaTypes = [
    "audio",
    "video"
]

private let viewableTypes = [
    "image"
]

extension ObjectPreview {
    var isMedia: Bool {
        mediaTypes.contains(self.type)
    }

    var isViewable: Bool {
        viewableTypes.contains(self.type)
    }

    var mimeType: String {
        "\(self.type)/\(self.subtype)"
    }
}

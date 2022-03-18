import Minty

extension Object {
    var mimeType: String {
        "\(self.type)/\(self.subtype)"
    }
}

import Foundation

private let byteCountFormatter = ByteCountFormatter()

extension Int64 {
    var asByteCount: String {
        byteCountFormatter.string(fromByteCount: self)
    }
}

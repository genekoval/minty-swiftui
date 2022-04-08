import Minty
import Combine

extension Post {
    static let created = PassthroughSubject<String, Never>()
    static let deleted = PassthroughSubject<String, Never>()
}

extension Tag {
    static let deleted = PassthroughSubject<String, Never>()
}

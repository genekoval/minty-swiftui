import Combine
import Foundation
import Minty

extension Post {
    static let deleted = PassthroughSubject<UUID, Never>()
    static let published = PassthroughSubject<UUID, Never>()
}

extension Tag {
    static let deleted = PassthroughSubject<UUID, Never>()
}

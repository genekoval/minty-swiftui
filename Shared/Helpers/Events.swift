import Combine

struct Events {
    static let postCreated = PassthroughSubject<String, Never>()

    static let postDeleted = PassthroughSubject<String, Never>()

    static let tagDeleted = PassthroughSubject<String, Never>()
}

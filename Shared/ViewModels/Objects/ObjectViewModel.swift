import Combine
import Foundation
import Minty

final class ObjectViewModel: IdentifiableEntity, ObservableObject {
    @Published var object = Object()
    @Published var posts: [PostViewModel] = []

    init(id: UUID) {
        super.init(id: id, identifier: "object")
    }

    override func refresh() throws {
        try withRepo("fetch data") { repo in
            object = try repo.getObject(objectId: id)
            posts = object.posts.map { app!.state.posts.fetch(for: $0) }
        }
    }
}

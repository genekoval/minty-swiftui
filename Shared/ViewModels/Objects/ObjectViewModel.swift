import Combine
import Foundation
import Minty

final class ObjectViewModel: IdentifiableEntity, ObservableObject {
    @Published var object: Object?
    @Published var posts: [PostViewModel] = []

    init(id: UUID) {
        super.init(id: id, identifier: "object")
    }

    override func refresh() async throws {
        try await withRepo("fetch data") { repo in
            let object = try await repo.getObject(id: id)
            posts = object.posts.map { app!.state.posts.fetch(for: $0) }
            self.object = object
        }
    }
}

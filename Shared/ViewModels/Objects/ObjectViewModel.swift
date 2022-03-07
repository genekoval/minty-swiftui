import Combine
import Minty

final class ObjectViewModel: IdentifiableEntity, ObservableObject {
    @Published var object = Object()

    init(id: String) {
        super.init(id: id, identifier: "object")
    }

    override func refresh() throws {
        try withRepo("fetch data") { repo in
            object = try repo.getObject(objectId: id)
        }
    }
}

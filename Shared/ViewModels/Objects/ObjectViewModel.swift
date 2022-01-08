import Combine
import Minty

final class ObjectViewModel: IdentifiableEntity, ObservableObject {
    @Published var object = Object()

    init(id: String, repo: MintyRepo?) {
        super.init(id: id, identifier: "object", repo: repo)
    }

    override func refresh() {
        withRepo("fetch data") { repo in
            object = try repo.getObject(objectId: id)
        }
    }
}

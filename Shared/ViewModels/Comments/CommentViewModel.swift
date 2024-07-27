import Combine
import Foundation
import Minty

final class CommentViewModel: 
    IdentifiableEntity, 
    ObservableObject,
    StorableEntity
{
    static let deleted = PassthroughSubject<Comment.ID, Never>()

    @Published var content = ""
    @Published var draftContent = ""
    @Published var draftReply = ""
    @Published var user: User?

    var post: PostViewModel?

    private(set) var level = 0
    private(set) var created = Date()

    private var contentCancellable: AnyCancellable?
    private weak var storage: CommentState?

    init(id: Comment.ID, storage: CommentState?) {
        super.init(id: id, identifier: "comment")

        self.storage = storage

        contentCancellable = $content.sink { [weak self] in
            self?.draftContent = $0
        }
    }

    deinit {
        storage?.remove(self)
    }

    func delete() {
        content.removeAll()
        user?.commentCount -= 1
        post?.commentCount -= 1
    }

    func load(from comment: CommentData) {
        content = comment.content
        level = comment.level
        created = comment.created
    }
}

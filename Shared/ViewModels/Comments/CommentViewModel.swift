import Combine
import Foundation
import Minty

final class CommentViewModel: 
    IdentifiableEntity, 
    ObservableObject,
    StorableEntity
{
    static let deleted = PassthroughSubject<CommentDetail.ID, Never>()

    @Published var content = ""
    @Published var draftContent = ""
    @Published var draftReply = ""

    var post: PostViewModel?

    private(set) var indent = 0
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
        post?.commentCount -= 1
    }

    func load(from comment: Comment) {
        content = comment.content
        indent = comment.indent
        created = comment.dateCreated
    }
}

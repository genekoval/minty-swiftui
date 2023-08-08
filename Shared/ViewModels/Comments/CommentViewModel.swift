import Combine
import Foundation
import Minty

final class CommentViewModel: IdentifiableEntity, ObservableObject {
    @Published var content = ""
    @Published var draftContent = ""
    @Published var draftReply = ""

    let indent: Int
    let created: Date

    private var contentCancellable: AnyCancellable?

    init(comment: Comment, post: PostViewModel) {
        self.content = comment.content
        self.indent = Int(comment.indent)
        self.created = comment.dateCreated

        super.init(id: comment.id, identifier: "comment")
        self.app = post.app

        contentCancellable = $content.sink { [weak self] in
            self?.draftContent = $0
        }
    }
}

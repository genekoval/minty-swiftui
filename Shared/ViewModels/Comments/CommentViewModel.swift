import Combine
import Foundation
import Minty

final class CommentViewModel: IdentifiableEntity, ObservableObject {
    @Published var draftContent = ""
    @Published var draftReply = ""

    @Published private(set) var content = ""

    let indent: Int
    let created: Date

    private var contentCancellable: AnyCancellable?
    private let post: PostViewModel

    init(comment: Comment, post: PostViewModel) {
        self.content = comment.content
        self.indent = Int(comment.indent)
        self.created = comment.dateCreated
        self.post = post

        super.init(id: comment.id, identifier: "comment", repo: post.repo)

        contentCancellable = $content.sink { [weak self] in
            self?.draftContent = $0
        }
    }

    func commitContent() {
        if draftContent == content { return }

        withRepo("update content") { repo in
            content = try repo.setCommentContent(
                commentId: id,
                content: draftContent
            )
        }
    }

    func reply() {
        withRepo("add reply") { repo in
            let comment = try repo.addComment(
                postId: post.id,
                parentId: id,
                content: draftReply
            )

            post.add(reply: comment, to: id)
        }
    }
}

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

        super.init(id: comment.id, identifier: "comment")
        self.app = post.app

        contentCancellable = $content.sink { [weak self] in
            self?.draftContent = $0
        }
    }

    func commitContent() async throws {
        if draftContent == content { return }

        try await withRepo("update content") { repo in
            content = try await repo.set(
                comment: id,
                content: draftContent
            )
        }
    }

    func reply() async throws {
        try await withRepo("add reply") { repo in
            let comment = try await repo.reply(
                to: id,
                content: draftReply
            )

            try post.add(reply: comment, to: id)
            draftReply.removeAll()
        }
    }
}

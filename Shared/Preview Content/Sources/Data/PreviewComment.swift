import Foundation
import Minty

struct PreviewComment {
    static let first = UUID(uuidString: "317517c8-da22-4bdc-8624-5c5633e60dcb")!
    static let long = UUID(uuidString: "ecf9a2b4-197a-4416-9a79-b51060d9d4d3")!
}

private final class PreviewData {
    private(set) var comments: [UUID: Comment] = [:]
    private(set) var posts: [UUID: [UUID]] = [:]

    init() {
        addComment(
            post: PreviewPost.test,
            id: PreviewComment.first,
            content: "First."
        )

        addComment(
            post: PreviewPost.test,
            id: PreviewComment.long,
            content: "Vivamus sollicitudin leo sed quam bibendum imperdiet. Nulla libero urna, aliquet in nibh et, tristique aliquam ipsum. Integer sit amet rutrum ex, id bibendum turpis. Proin blandit malesuada nunc in gravida. Etiam finibus aliquet porttitor. Nullam ut fermentum nisi. Proin nec arcu eget libero fringilla fermentum feugiat at lorem. Praesent nulla est, venenatis quis risus eget, auctor porttitor tellus. Proin scelerisque rutrum accumsan.",
            indent: 1
        )
    }

    private func addComment(
        post: UUID,
        id: UUID,
        content: String,
        indent: Int16 = 0,
        created: String? = nil
    ) {
        var comment = Comment()

        comment.id = id
        comment.content = content
        comment.indent = indent
        if let created = created { comment.dateCreated = Date(from: created) }

        comments[id] = comment

        var postComments = posts[post] ?? []
        postComments.append(id)

        posts[post] = postComments
    }
}

private let data = PreviewData()

extension Comment {
    static func preview(id: UUID) -> Comment {
        guard let comment = data.comments[id] else {
            fatalError("Comment with ID (\(id)) does not exist")
        }

        return comment
    }

    static func preview(for postId: UUID) -> [Comment] {
        guard let comments = data.posts[postId] else { return [] }
        return comments.map { Comment.preview(id: $0) }
    }
}

extension CommentViewModel {
    static func preview(id: UUID) -> CommentViewModel {
        var postId: UUID?

        for post in MintyUI.data.posts {
            for comment in post.value {
                if comment == id {
                    postId = post.key
                }
            }
        }

        guard let postId = postId else {
            fatalError("Comment with ID (\(id)) does not belong to a post")
        }

        let comment = Comment.preview(id: id)
        let post = PostViewModel.preview(id: postId)

        return CommentViewModel(comment: comment, post: post)
    }
}

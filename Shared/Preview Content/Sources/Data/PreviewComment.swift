import Foundation
import Minty

private final class PreviewData {
    private(set) var comments: [String: Comment] = [:]
    private(set) var posts: [String: [String]] = [:]

    init() {
        addComment(post: "test", id: "first", content: "First.")

        addComment(
            post: "test",
            id: "long",
            content: "Vivamus sollicitudin leo sed quam bibendum imperdiet. Nulla libero urna, aliquet in nibh et, tristique aliquam ipsum. Integer sit amet rutrum ex, id bibendum turpis. Proin blandit malesuada nunc in gravida. Etiam finibus aliquet porttitor. Nullam ut fermentum nisi. Proin nec arcu eget libero fringilla fermentum feugiat at lorem. Praesent nulla est, venenatis quis risus eget, auctor porttitor tellus. Proin scelerisque rutrum accumsan.",
            indent: 1
        )
    }

    private func addComment(
        post: String,
        id: String,
        content: String,
        indent: UInt32 = 0,
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
    static func preview(id: String) -> Comment {
        guard let comment = data.comments[id] else {
            fatalError("Comment with ID (\(id)) does not exist")
        }

        return comment
    }

    static func preview(for postId: String) -> [Comment] {
        guard let comments = data.posts[postId] else { return [] }
        return comments.map { Comment.preview(id: $0) }
    }
}

extension CommentViewModel {
    static func preview(id: String) -> CommentViewModel {
        var postId: String?

        for post in data.posts {
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

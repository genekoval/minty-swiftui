import Foundation
import Minty

private final class PreviewData {
    private(set) var posts: [String: Post] = [:]
    private(set) var previews: [String: PostPreview] = [:]

    init() {
        addPost(
            id: "sand dune",
            title: "Sand Dune",
            description: "Photo take by Eugene Ga in Merzouga, Morocco.",
            created: "2020-12-29 12:00:00.000-04",
            objects: ["sand dune.jpg"],
            tags: ["1"]
        )

        addPost(
            id: "test",
            title: "This is a test post. Vivamus sollicitudin leo sed quam bibendum imperdiet. Nulla libero urna, aliquet in nibh et, tristique aliquam ipsum.",
            description: "Vivamus sollicitudin leo sed quam bibendum imperdiet. Nulla libero urna, aliquet in nibh et, tristique aliquam ipsum. Integer sit amet rutrum ex, id bibendum turpis. Proin blandit malesuada nunc in gravida. Etiam finibus aliquet porttitor. Nullam ut fermentum nisi. Proin nec arcu eget libero fringilla fermentum feugiat at lorem. Praesent nulla est, venenatis quis risus eget, auctor porttitor tellus. Proin scelerisque rutrum accumsan.",
            created: "2018-10-27 10:15:36.285-04",
            modified: 60_000,
            objects: ["empty", "sand dune.jpg"],
            tags: ["1", "empty"]
        )

        addPost(
            id: "untitled",
            description: "This post has no title.",
            objects: ["empty"],
            tags: ["1"]
        )
    }

    func addPost(
        id: String,
        title: String? = nil,
        description: String? = nil,
        created: String? = nil,
        modified: TimeInterval? = nil,
        objects: [String] = [],
        tags: [String] = []
    ) {
        var post = Post()

        post.id = id
        post.title = title
        post.description = description
        if let date = created { post.dateCreated = Date(from: date) }
        if let interval = modified {
            post.dateModified = post.dateCreated.addingTimeInterval(interval)
        }
        else {
            post.dateModified = post.dateCreated
        }
        post.objects = objects.map { ObjectPreview.preview(id: $0) }
        post.tags = tags.map { TagPreview.preview(id: $0) }

        setPost(post: post)
    }

    func getPosts(query: PostQuery) -> [PostPreview] {
        var results = [Post](posts.values)

        if let text = query.text {
            results.removeAll { post in
                guard let title = post.title else { return true }
                return !title.starts(with: text)
            }
        }

        if !query.tags.isEmpty {
            for tag in query.tags {
                results.removeAll { !$0.tags.map { $0.id }.contains(tag) }
            }
        }

        results.sort {
            var result = true

            switch (query.sort.value) {
            case .dateCreated:
                result = $0.dateCreated < $1.dateCreated
            case .dateModified:
                result = $0.dateModified < $1.dateModified
            case .title:
                result = ($0.title ?? "") < ($1.title ?? "")
            case .relevance:
                result = $0.id < $1.id
            }

            return query.sort.order == .ascending ? result : !result
        }

        return results.map { previews[$0.id]! }
    }

    func setPost(post: Post) {
        posts[post.id] = post

        var preview = PostPreview()

        preview.id = post.id
        preview.title = post.title
        preview.previewId = post.objects.first?.previewId
        preview.objectCount = UInt32(post.objects.count)
        preview.dateCreated = post.dateCreated

        previews[post.id] = preview
    }
}

private let data = PreviewData()

extension Post {
    static func preview(id: String) -> Post {
        if let post = data.posts[id] { return post }
        fatalError("Post with ID (\(id)) does not exist")
    }
}

extension PostPreview {
    static func preview(id: String) -> PostPreview {
        if let preview = data.previews[id] { return preview }
        fatalError("Post Preview with ID (\(id)) does not exist")
    }

    static func preview(query: PostQuery) -> [PostPreview] {
        data.getPosts(query: query)
    }
}

extension PostQueryViewModel {
    static func preview() -> PostQueryViewModel {
        PostQueryViewModel(repo: PreviewRepo())
    }
}

extension PostViewModel {
    static func preview(id: String) -> PostViewModel {
        PostViewModel(id: id, repo: PreviewRepo())
    }
}

import Foundation
import Minty

struct PreviewPost {
    static let sandDune =
        UUID(uuidString: "ad79e229-1152-43a5-95b8-476c5bd5b84e")!
    static let test = UUID(uuidString: "fb72901c-9130-48ea-b6b8-e64504f3f7bf")!
    static let untitled =
        UUID(uuidString: "515258b4-391a-49e8-aa94-f05e7b1b5aad")!
}

private final class PreviewData {
    private(set) var posts: [UUID: Post] = [:]
    private(set) var previews: [UUID: PostPreview] = [:]

    init() {
        addPost(
            id: PreviewPost.sandDune,
            title: "Sand Dune",
            description: "Photo take by Eugene Ga in Merzouga, Morocco.",
            created: "2020-12-29 12:00:00.000-04",
            objects: [PreviewObject.sandDune],
            tags: [PreviewTag.helloWorld]
        )

        addPost(
            id: PreviewPost.test,
            title: "This is a test post. Vivamus sollicitudin leo sed quam bibendum imperdiet. Nulla libero urna, aliquet in nibh et, tristique aliquam ipsum.",
            description: "Vivamus sollicitudin leo sed quam bibendum imperdiet. Nulla libero urna, aliquet in nibh et, tristique aliquam ipsum. Integer sit amet rutrum ex, id bibendum turpis. Proin blandit malesuada nunc in gravida. Etiam finibus aliquet porttitor. Nullam ut fermentum nisi. Proin nec arcu eget libero fringilla fermentum feugiat at lorem. Praesent nulla est, venenatis quis risus eget, auctor porttitor tellus. Proin scelerisque rutrum accumsan.",
            created: "2018-10-27 10:15:36.285-04",
            modified: 60_000,
            objects: [PreviewObject.empty, PreviewObject.sandDune],
            posts: [PreviewPost.sandDune],
            tags: [PreviewTag.helloWorld, PreviewTag.empty]
        )

        addPost(
            id: PreviewPost.untitled,
            description: "This post has no title.",
            objects: [PreviewObject.empty],
            tags: [PreviewTag.helloWorld]
        )
    }

    func addPost(parts: PostParts) -> UUID {
        let id = UUID()

        addPost(
            id: id,
            title: parts.title,
            description: parts.description,
            objects: parts.objects,
            tags: parts.tags
        )

        return id
    }

    private func addPost(
        id: UUID,
        title: String? = nil,
        description: String? = nil,
        created: String? = nil,
        modified: TimeInterval? = nil,
        objects: [UUID] = [],
        posts: [UUID] = [],
        tags: [UUID] = []
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
        post.posts = posts.map { previews[$0]! }
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
                // Sorting by relevance currently does nothing
                result = true
            }

            return query.sort.order == .ascending ? result : !result
        }

        return results.map { previews[$0.id]! }
    }

    func removePost(id: UUID) {
        previews.removeValue(forKey: id)
        posts.removeValue(forKey: id)
    }

    func setPost(post: Post) {
        posts[post.id] = post

        var preview = PostPreview()

        preview.id = post.id
        preview.title = post.title
        preview.preview = post.objects.first
        preview.objectCount = UInt32(post.objects.count)
        preview.dateCreated = post.dateCreated

        previews[post.id] = preview
    }
}

private let data = PreviewData()

extension Post {
    static func preview(add parts: PostParts) -> UUID {
        return data.addPost(parts: parts)
    }

    static func preview(edit id: UUID, action: (inout Post) -> Void) {
        var post = Post.preview(id: id)
        action(&post)
        data.setPost(post: post)
    }

    static func preview(id: UUID) -> Post {
        if let post = data.posts[id] { return post }
        fatalError("Post with ID (\(id)) does not exist")
    }

    static func preview(remove id: UUID) {
        data.removePost(id: id)
    }
}

extension PostPreview {
    static func preview(id: UUID) -> PostPreview {
        guard let preview = data.previews[id] else {
            fatalError("Post Preview with ID (\(id)) does not exist")
        }

        return preview
    }

    static func preview(query: PostQuery) -> [PostPreview] {
        data.getPosts(query: query)
    }
}

extension PostQueryViewModel {
    static func preview(searchNow: Bool = false) -> PostQueryViewModel {
        PostQueryViewModel(searchNow: searchNow)
    }
}

extension PostViewModel {
    static func preview(id: UUID) -> PostViewModel {
        PostViewModel(id: id, storage: nil)
    }
}

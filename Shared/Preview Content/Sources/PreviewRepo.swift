import Foundation
import Minty

final class PreviewRepo: MintyRepo {
    func addComment(
        postId: String,
        parentId: String?,
        content: String
    ) throws -> Comment {
        throw PreviewError.notSupported
    }

    func addObjectData(
        count: Int,
        data: @escaping (DataWriter) -> Void
    ) throws -> ObjectPreview {
        throw PreviewError.notSupported
    }

    func addObjectsUrl(url: String) throws -> [ObjectPreview] {
        throw PreviewError.notSupported
    }

    func addPost(parts: PostParts) throws -> String {
        return Post.preview(add: parts)
    }

    func addPostObjects(
        postId: String,
        objects: [String],
        position: UInt32
    ) throws -> Date {
        let previews = objects.map { ObjectPreview.preview(id: $0) }

        Post.preview(edit: postId) { post in
            post.objects.insert(contentsOf: previews, at: Int(position))
        }

        return Date()
    }

    func addPostTag(postId: String, tagId: String) throws {
        Post.preview(edit: postId) { post in
            post.tags.append(TagPreview.preview(id: tagId))
        }
    }

    func addRelatedPost(postId: String, related: String) throws {
        Post.preview(edit: postId) { post in
            post.posts.append(PostPreview.preview(id: related))
        }
    }

    func addTag(name: String) throws -> String {
        Tag.preview(add: name)
    }

    func addTagAlias(tagId: String, alias: String) throws -> TagName {
        Tag.preview(edit: tagId) { $0.aliases.append(alias) }
        return Tag.preview(namesFor: tagId)
    }

    func addTagSource(tagId: String, url: String) throws -> Source {
        let source = Source.preview(add: url)
        Tag.preview(edit: tagId) { $0.sources.append(source) }
        return source
    }

    func deletePost(postId: String) throws {
        Post.preview(remove: postId)
    }

    func deletePostObjects(postId: String, objects: [String]) throws -> Date {
        Post.preview(edit: postId) { post in
            for id in objects {
                if let index = post.objects.firstIndex(where: { $0.id == id }) {
                    post.objects.remove(at: index)
                }
            }
        }

        return Date()
    }

    func deletePostObjects(
        postId: String,
        ranges: [Range<Int32>]
    ) throws -> Date {
        throw PreviewError.notSupported
    }

    func deletePostTag(postId: String, tagId: String) throws {
        Post.preview(edit: postId) { post in
            if let index = post.tags.firstIndex(where: { $0.id == tagId }) {
                post.tags.remove(at: index)
            }
        }
    }

    func deleteRelatedPost(postId: String, related: String) throws {
        Post.preview(edit: postId) { post in
            if let index = post.posts.firstIndex(where: { $0.id == related }) {
                post.posts.remove(at: index)
            }
        }
    }

    func deleteTag(tagId: String) throws {
        Tag.preview(remove: tagId)
    }

    func deleteTagAlias(tagId: String, alias: String) throws -> TagName {
        var tag = Tag.preview(id: tagId)
        tag.aliases.removeAll { $0 == alias }

        Tag.preview(set: tag)

        var result = TagName()
        result.name = tag.name
        result.aliases = tag.aliases

        return result
    }

    func deleteTagSource(tagId: String, sourceId: String) throws {
        Tag.preview(edit: tagId) { tag in
            tag.sources.removeAll { $0.id == sourceId }
        }
    }

    func getComments(postId: String) throws -> [Comment] {
        Comment.preview(for: postId)
    }

    func getObject(objectId: String) throws -> Object {
        Object.preview(id: objectId)
    }

    func getObjectData(
        objectId: String,
        handler: (Data) throws -> Void
    ) throws {
        throw PreviewError.notSupported
    }

    func getPost(postId: String) throws -> Post {
        Post.preview(id: postId)
    }

    func getPosts(query: PostQuery) throws -> SearchResult<PostPreview> {
        let posts = PostPreview.preview(query: query)
        var result = SearchResult<PostPreview>()

        result.hits = posts
        result.total = UInt32(posts.count)

        return result
    }

    func getServerInfo() throws -> ServerInfo {
        throw PreviewError.notSupported
    }

    func getTag(tagId: String) throws -> Tag {
        Tag.preview(id: tagId)
    }

    func getTags(query: TagQuery) throws -> SearchResult<TagPreview> {
        let tags = TagPreview.preview(query: query.name)
        var result = SearchResult<TagPreview>()

        result.total = UInt32(tags.count)
        result.hits = tags

        return result
    }

    func movePostObject(
        postId: String,
        oldIndex: UInt32,
        newIndex: UInt32
    ) throws {
        Post.preview(edit: postId) { post in
            let source = IndexSet(integer: Int(oldIndex))
            let destination = Int(newIndex)

            post.objects.move(fromOffsets: source, toOffset: destination)
        }
    }

    func movePostObjects(
        postId: String,
        objects: [String],
        destination: String?
    ) throws -> Date {
        Post.preview(edit: postId) { post in
            let source = IndexSet(objects.map { object in
                post.objects.firstIndex(where: { $0.id == object })!
            })

            let destination = destination == nil ? post.objects.count :
                post.objects.firstIndex(where: { $0.id == destination })!

            post.objects.move(fromOffsets: source, toOffset: destination)
        }

        return Date()
    }

    func setCommentContent(
        commentId: String,
        content: String
    ) throws -> String {
        throw PreviewError.notSupported
    }

    func setPostDescription(
        postId: String,
        description: String
    ) throws -> Modification<String?> {
        let result = Modification<String?>(
            newValue: description.isEmpty ? nil : description
        )
        Post.preview(edit: postId) { $0.description = result.newValue }
        return result
    }

    func setPostTitle(
        postId: String,
        title: String
    ) throws -> Modification<String?> {
        let result = Modification<String?>(
            newValue: title.isEmpty ? nil : title
        )
        Post.preview(edit: postId) { $0.title = result.newValue }
        return result
    }

    func setTagDescription(
        tagId: String,
        description: String
    ) throws -> String? {
        let value = description.isEmpty ? nil : description
        Tag.preview(edit: tagId) { $0.description = value }
        return value
    }

    func setTagName(tagId: String, newName: String) throws -> TagName {
        var tag = Tag.preview(id: tagId)
        tag.name = newName

        Tag.preview(set: tag)

        var result = TagName()
        result.name = tag.name
        result.aliases = tag.aliases

        return result
    }
}

extension DataSource {
    static let preview = DataSource(
        connect: { _ in PreviewRepo() },
        repo: PreviewRepo()
    )
}

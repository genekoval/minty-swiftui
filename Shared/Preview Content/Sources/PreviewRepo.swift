import Foundation
import Minty

final class PreviewRepo: MintyRepo {
    func addComment(postId: UUID, content: String) async throws -> Comment {
        throw PreviewError.notSupported
    }

    func addObjectData(
        size: Int,
        writer: @escaping (DataWriter) async throws -> Void
    ) async throws -> ObjectPreview {
        throw PreviewError.notSupported
    }

    func addObjectsUrl(url: String) async throws -> [ObjectPreview] {
        throw PreviewError.notSupported
    }

    func addPost(parts: PostParts) async throws -> UUID {
        return Post.preview(add: parts)
    }

    func addPostObjects(
        postId: UUID,
        objects: [UUID],
        position: Int16
    ) async throws -> Date {
        let previews = objects.map { ObjectPreview.preview(id: $0) }

        Post.preview(edit: postId) { post in
            post.objects.insert(contentsOf: previews, at: Int(position))
        }

        return Date()
    }

    func addPostTag(postId: UUID, tagId: UUID) async throws {
        Post.preview(edit: postId) { post in
            post.tags.append(TagPreview.preview(id: tagId))
        }
    }

    func addRelatedPost(postId: UUID, related: UUID) async throws {
        Post.preview(edit: postId) { post in
            post.posts.append(PostPreview.preview(id: related))
        }
    }

    func addReply(parentId: UUID, content: String) async throws -> Comment {
        throw PreviewError.notSupported
    }

    func addTag(name: String) async throws -> UUID {
        Tag.preview(add: name)
    }

    func addTagAlias(tagId: UUID, alias: String) async throws -> TagName {
        Tag.preview(edit: tagId) { $0.aliases.append(alias) }
        return Tag.preview(namesFor: tagId)
    }

    func addTagSource(tagId: UUID, url: String) async throws -> Source {
        let source = Source.preview(add: url)
        Tag.preview(edit: tagId) { $0.sources.append(source) }
        return source
    }

    func deletePost(postId: UUID) async throws {
        Post.preview(remove: postId)
    }

    func deletePostObjects(postId: UUID, objects: [UUID]) async throws -> Date {
        Post.preview(edit: postId) { post in
            for id in objects {
                post.objects.remove(id: id)
            }
        }

        return Date()
    }

    func deletePostObjects(
        postId: UUID,
        ranges: [Range<Int32>]
    ) async throws -> Date {
        throw PreviewError.notSupported
    }

    func deletePostTag(postId: UUID, tagId: UUID) async throws {
        Post.preview(edit: postId) { post in
            post.tags.remove(id: tagId)
        }
    }

    func deleteRelatedPost(postId: UUID, related: UUID) async throws {
        Post.preview(edit: postId) { post in
            post.posts.remove(id: related)
        }
    }

    func deleteTag(tagId: UUID) async throws {
        Tag.preview(remove: tagId)
    }

    func deleteTagAlias(tagId: UUID, alias: String) async throws -> TagName {
        var tag = Tag.preview(id: tagId)
        tag.aliases.removeAll { $0 == alias }

        Tag.preview(set: tag)

        var result = TagName()
        result.name = tag.name
        result.aliases = tag.aliases

        return result
    }

    func deleteTagSource(tagId: UUID, sourceId: String) async throws {
        Tag.preview(edit: tagId) { tag in
            tag.sources.removeAll { $0.id == sourceId }
        }
    }

    func getComment(commentId: UUID) async throws -> CommentDetail {
        throw PreviewError.notSupported
    }

    func getComments(postId: UUID) async throws -> [Comment] {
        Comment.preview(for: postId)
    }

    func getObject(objectId: UUID) async throws -> Object {
        Object.preview(id: objectId)
    }

    func getObjectData(
        objectId: UUID,
        handler: (Data) async throws -> Void
    ) async throws {
        throw PreviewError.notSupported
    }

    func getPost(postId: UUID) async throws -> Post {
        Post.preview(id: postId)
    }

    func getPosts(query: PostQuery) async throws -> SearchResult<PostPreview> {
        let posts = PostPreview.preview(query: query)
        var result = SearchResult<PostPreview>()

        result.hits = posts
        result.total = UInt32(posts.count)

        return result
    }

    func getServerInfo() async throws -> ServerInfo {
        throw PreviewError.notSupported
    }

    func getTag(tagId: UUID) async throws -> Tag {
        Tag.preview(id: tagId)
    }

    func getTags(query: TagQuery) async throws -> SearchResult<TagPreview> {
        let tags = TagPreview.preview(query: query.name)
        var result = SearchResult<TagPreview>()

        result.total = UInt32(tags.count)
        result.hits = tags

        return result
    }

    func movePostObject(
        postId: UUID,
        oldIndex: UInt32,
        newIndex: UInt32
    ) async throws {
        Post.preview(edit: postId) { post in
            let source = IndexSet(integer: Int(oldIndex))
            let destination = Int(newIndex)

            post.objects.move(fromOffsets: source, toOffset: destination)
        }
    }

    func movePostObjects(
        postId: UUID,
        objects: [UUID],
        destination: UUID?
    ) async throws -> Date {
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
        commentId: UUID,
        content: String
    ) async throws -> String {
        throw PreviewError.notSupported
    }

    func setPostDescription(
        postId: UUID,
        description: String
    ) async throws -> Modification<String?> {
        let result = Modification<String?>(
            newValue: description.isEmpty ? nil : description
        )
        Post.preview(edit: postId) { $0.description = result.newValue }
        return result
    }

    func setPostTitle(
        postId: UUID,
        title: String
    ) async throws -> Modification<String?> {
        let result = Modification<String?>(
            newValue: title.isEmpty ? nil : title
        )
        Post.preview(edit: postId) { $0.title = result.newValue }
        return result
    }

    func setTagDescription(
        tagId: UUID,
        description: String
    ) async throws -> String? {
        let value = description.isEmpty ? nil : description
        Tag.preview(edit: tagId) { $0.description = value }
        return value
    }

    func setTagName(tagId: UUID, newName: String) async throws -> TagName {
        var tag = Tag.preview(id: tagId)
        tag.name = newName

        Tag.preview(set: tag)

        var result = TagName()
        result.name = tag.name
        result.aliases = tag.aliases

        return result
    }
}

private func connect(
    server: Server
) async throws -> (MintyRepo, ServerMetadata) {
    var metadata = ServerMetadata()
    metadata.version = "0.0.0"

    return (PreviewRepo(), metadata)
}

extension DataSource {
    static let preview = DataSource(connect: connect)
}

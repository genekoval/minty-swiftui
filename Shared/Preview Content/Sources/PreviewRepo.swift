import Foundation
import Minty

private final class PreviewRepo: MintyRepo {
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
    ) throws -> String {
        throw PreviewError.notSupported
    }

    func addObjectsUrl(url: String) throws -> [String] {
        throw PreviewError.notSupported
    }

    func addPost(parts: PostParts) throws -> String {
        throw PreviewError.notSupported
    }

    func addPostObjects(
        postId: String,
        objects: [String],
        position: UInt32
    ) throws -> [ObjectPreview] {
        throw PreviewError.notSupported
    }

    func addPostTag(postId: String, tagId: String) throws {
        throw PreviewError.notSupported
    }

    func addTag(name: String) throws -> String {
        Tag.preview(add: name)
    }

    func addTagAlias(tagId: String, alias: String) throws -> TagName {
        throw PreviewError.notSupported
    }

    func addTagSource(tagId: String, url: String) throws -> Source {
        throw PreviewError.notSupported
    }

    func deletePost(postId: String) throws {
        throw PreviewError.notSupported
    }

    func deletePostObjects(postId: String, ranges: [Range<Int32>]) throws {
        throw PreviewError.notSupported
    }

    func deletePostTag(postId: String, tagId: String) throws {
        throw PreviewError.notSupported
    }

    func deleteTag(tagId: String) throws {
        throw PreviewError.notSupported
    }

    func deleteTagAlias(tagId: String, alias: String) throws -> TagName {
        throw PreviewError.notSupported
    }

    func deleteTagSource(tagId: String, sourceId: String) throws {
        throw PreviewError.notSupported
    }

    func getComments(postId: String) throws -> [Comment] {
        throw PreviewError.notSupported
    }

    func getObject(objectId: String) throws -> Object {
        throw PreviewError.notSupported
    }

    func getObjectData(objectId: String, handler: (Data) -> Void) throws {
        throw PreviewError.notSupported
    }

    func getPost(postId: String) throws -> Post {
        throw PreviewError.notSupported
    }

    func getPosts(query: PostQuery) throws -> SearchResult<PostPreview> {
        throw PreviewError.notSupported
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
        throw PreviewError.notSupported
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
    ) throws -> String? {
        throw PreviewError.notSupported
    }

    func setPostTitle(postId: String, title: String) throws -> String? {
        throw PreviewError.notSupported
    }

    func setTagDescription(
        tagId: String,
        description: String
    ) throws -> String? {
        throw PreviewError.notSupported
    }

    func setTagName(tagId: String, newName: String) throws -> TagName {
        throw PreviewError.notSupported
    }
}

extension DataSource {
    static let preview = DataSource(
        connect: { _ in PreviewRepo() },
        repo: PreviewRepo()
    )
}

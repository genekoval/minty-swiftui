import Foundation
import Minty

struct PreviewTag {
    static let empty = UUID(uuidString: "3bc56fa7-010f-4d2e-be9b-3e1b077ea215")!
    static let helloWorld =
        UUID(uuidString: "6b99b219-1016-4a78-9204-a35636ad6b3e")!
}

private class PreviewData {
    private(set) var previews: [UUID: TagPreview] = [:]
    private(set) var tags: [UUID: Tag] = [:]

    init() {
        addTag(
            id: PreviewTag.helloWorld,
            name: "Hello World",
            aliases: ["Foo", "Bar", "Baz"],
            description: "Vivamus sollicitudin leo sed quam bibendum imperdiet. Nulla libero urna, aliquet in nibh et, tristique aliquam ipsum. Integer sit amet rutrum ex, id bibendum turpis. Proin blandit malesuada nunc in gravida. Etiam finibus aliquet porttitor. Nullam ut fermentum nisi. Proin nec arcu eget libero fringilla fermentum feugiat at lorem. Praesent nulla est, venenatis quis risus eget, auctor porttitor tellus. Proin scelerisque rutrum accumsan.",
            dateCreated: "2021-10-16 12:00:36.285634-04",
            sources: ["1", "2"]
        )

        addTag(
            id: PreviewTag.empty,
            name: "Empty Tag",
            dateCreated: "2021-05-12 5:00:00.000-04"
        )
    }

    func addTag(
        id: UUID,
        name: String,
        aliases: [String] = [],
        description: String? = nil,
        dateCreated: String? = nil,
        sources: [String] = []
    ) {
        var tag = Tag()

        tag.id = id
        tag.name = name
        tag.aliases = aliases
        tag.description = description
        if let date = dateCreated { tag.dateCreated = Date(from: date) }
        tag.sources = sources.map { Source.preview(id: $0) }

        setTag(tag: tag)
    }

    func getTags(query: String) -> [TagPreview] {
        let values = [TagPreview](previews.values)
        let results = values.drop { !$0.name.starts(with: query) }
        return [TagPreview](results)
    }

    func removeTag(id: UUID) {
        previews.removeValue(forKey: id)
        tags.removeValue(forKey: id)
    }

    func setTag(tag: Tag) {
        tags[tag.id] = tag

        var preview = TagPreview()
        preview.id = tag.id
        preview.name = tag.name

        previews[tag.id] = preview
    }
}

private let data = PreviewData()

extension Tag {
    static func preview(add name: String) -> UUID {
        let id = UUID()
        data.addTag(id: id, name: name)
        return id
    }

    static func preview(edit id: UUID, action: (inout Tag) -> Void) {
        var tag = Tag.preview(id: id)
        action(&tag)
        data.setTag(tag: tag)
    }

    static func preview(id: UUID) -> Tag {
        guard var tag = data.tags[id] else {
            fatalError("Tag with ID (\(id)) does not exist")
        }

        var query = PostQuery()
        query.tags.append(id)

        let posts = PostPreview.preview(query: query)
        tag.postCount = UInt32(posts.count)

        return tag
    }

    static func preview(namesFor id: UUID) -> TagName {
        let tag = Tag.preview(id: id)
        var result = TagName()
        result.name = tag.name
        result.aliases = tag.aliases
        return result
    }

    static func preview(remove id: UUID) {
        data.removeTag(id: id)
    }

    static func preview(set tag: Tag) {
        data.setTag(tag: tag)
    }
}

extension TagPreview {
    static func preview(id: UUID) -> TagPreview {
        guard let preview = data.previews[id] else {
            fatalError("Tag Preview with ID (\(id)) does not exist")
        }

        return preview
    }

    static func preview(query: String) -> [TagPreview] {
        data.getTags(query: query)
    }
}

extension TagQueryViewModel {
    static func preview() -> TagQueryViewModel {
        TagQueryViewModel()
    }
}

extension TagViewModel {
    static func preview(id: UUID) -> TagViewModel {
        TagViewModel(id: id, storage: nil)
    }
}

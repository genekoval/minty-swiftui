import Foundation
import Minty

private class PreviewData {
    private(set) var previews: [String: TagPreview] = [:]
    private(set) var tags: [String: Tag] = [:]

    init() {
        addTag(
            id: "1",
            name: "Hello World",
            aliases: ["Foo", "Bar", "Baz"],
            description: "Vivamus sollicitudin leo sed quam bibendum imperdiet. Nulla libero urna, aliquet in nibh et, tristique aliquam ipsum. Integer sit amet rutrum ex, id bibendum turpis. Proin blandit malesuada nunc in gravida. Etiam finibus aliquet porttitor. Nullam ut fermentum nisi. Proin nec arcu eget libero fringilla fermentum feugiat at lorem. Praesent nulla est, venenatis quis risus eget, auctor porttitor tellus. Proin scelerisque rutrum accumsan.",
            dateCreated: "2021-10-16 12:00:36.285634-04",
            sources: ["1", "2"]
        )
    }

    func addTag(
        id: String,
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

        tags[id] = tag

        var preview = TagPreview()

        preview.id = id
        preview.name = name

        previews[id] = preview
    }

    func getTags(query: String) -> [TagPreview] {
        let values = [TagPreview](previews.values)
        let results = values.drop { !$0.name.starts(with: query) }
        return [TagPreview](results)
    }
}

private let data = PreviewData()

extension Tag {
    static func preview(add name: String) -> String {
        let id = UUID().uuidString
        data.addTag(id: id, name: name)
        return id
    }

    static func preview(id: String) -> Tag {
        data.tags[id]!
    }
}

extension TagPreview {
    static func preview(id: String) -> TagPreview {
        data.previews[id]!
    }

    static func preview(query: String) -> [TagPreview] {
        data.getTags(query: query)
    }
}

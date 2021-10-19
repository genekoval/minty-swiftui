import Foundation
import Minty

private var previews: [String: TagPreview] = [:]

private let tags: [String: Tag] = {
    var result: [String: Tag] = [:]

    func tag(
        id: String,
        name: String,
        aliases: [String],
        description: String,
        dateCreated: String,
        sources: [String]
    ) {
        var tag = Tag()

        tag.id = id
        tag.name = name
        tag.aliases = aliases
        tag.description = description
        tag.dateCreated = Date(from: dateCreated)
        tag.sources = sources.map { Source.preview(id: $0) }

        result[id] = tag

        var preview = TagPreview()

        preview.id = id
        preview.name = name

        previews[id] = preview
    }

    tag(
        id: "1",
        name: "Hello World",
        aliases: ["Foo", "Bar", "Baz"],
        description: "Vivamus sollicitudin leo sed quam bibendum imperdiet. Nulla libero urna, aliquet in nibh et, tristique aliquam ipsum. Integer sit amet rutrum ex, id bibendum turpis. Proin blandit malesuada nunc in gravida. Etiam finibus aliquet porttitor. Nullam ut fermentum nisi. Proin nec arcu eget libero fringilla fermentum feugiat at lorem. Praesent nulla est, venenatis quis risus eget, auctor porttitor tellus. Proin scelerisque rutrum accumsan.",
        dateCreated: "2021-10-16 12:00:36.285634-04",
        sources: ["1", "2"]
    )

    return result
}()

extension Tag {
    static func preview(id: String) -> Tag {
        tags[id]!
    }
}

extension TagPreview {
    static func preview(id: String) -> TagPreview {
        previews[id]!
    }
}

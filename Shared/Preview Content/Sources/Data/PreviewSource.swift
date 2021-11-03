import Minty
import Foundation

private final class PreviewData {
    private(set) var sources: [String: Source] = [:]

    init() {
        addSource(id: "1", url: "https://example.com")
        addSource(
            id: "2",
            url: "https://en.wikipedia.org/wiki/%22Hello,_World!%22_program",
            icon: "wikipedia.png"
        )

        // Preview Object Sources
        addSource(
            id: "sand dune",
            url: "https://unsplash.com/photos/aL2jP0vi8nk",
            icon: "unsplash.png"
        )
    }

    @discardableResult
    func addSource(
        id: String,
        url: String,
        icon: String? = nil
    ) -> Source {
        var source = Source()

        source.id = id
        source.url = url
        source.icon = icon

        sources[id] = source
        return source
    }
}

private let data = PreviewData()

extension Source {
    static func preview(add url: String) -> Source {
        return data.addSource(id: UUID().uuidString, url: url)
    }

    static func preview(id: String) -> Source {
        data.sources[id]!
    }
}

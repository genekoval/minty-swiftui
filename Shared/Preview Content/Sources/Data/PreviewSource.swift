import Minty
import Foundation

private final class PreviewData {
    private(set) var sources: [Int64: Source] = [:]

    private var id: Int64 = 0

    init() {
        addSource(url: "https://example.com")
        addSource(
            url: "https://en.wikipedia.org/wiki/%22Hello,_World!%22_program",
            icon: PreviewObject.wikipedia
        )
        addSource(
            url: "https://unsplash.com/photos/aL2jP0vi8nk",
            icon: PreviewObject.unsplash
        )
    }

    @discardableResult
    func addSource(
        url: String,
        icon: UUID? = nil
    ) -> Source {
        var source = Source()

        source.id = id
        source.url = url
        source.icon = icon

        sources[id] = source

        id += 1
        return source
    }
}

private let data = PreviewData()

extension Source {
    static func preview(add url: String) -> Source {
        return data.addSource(url: url)
    }

    static func preview(id: Int64) -> Source {
        data.sources[id]!
    }
}

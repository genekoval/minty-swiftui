import Minty
import Foundation

private final class PreviewData {
    private(set) var sources: [String: Source] = [:]

    init() {
        addSource(id: "1", url: "https://example.com")
        addSource(
            id: "2",
            url: "https://en.wikipedia.org/wiki/%22Hello,_World!%22_program",
            icon: UUID(uuidString: "8b9f71fd-d344-4098-9f8c-8165b7d3c783")
        )
        addSource(
            id: "sand dune",
            url: "https://unsplash.com/photos/aL2jP0vi8nk",
            icon: UUID(uuidString: "fb4c62cf-fc57-415e-8651-1d2f25483221")
        )
    }

    @discardableResult
    func addSource(
        id: String,
        url: String,
        icon: UUID? = nil
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

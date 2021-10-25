import Minty

private let sources: [String: Source] = {
    var result: [String: Source] = [:]

    func source(id: String, url: String, icon: String? = nil) {
        var source = Source()

        source.id = id
        source.url = url
        source.icon = icon

        result[id] = source
    }

    source(id: "1", url: "https://example.com")
    source(
        id: "2",
        url: "https://en.wikipedia.org/wiki/%22Hello,_World!%22_program",
        icon: "wikipedia.png"
    )

    return result
}()

extension Source {
    static func preview(id: String) -> Source {
        sources[id]!
    }
}

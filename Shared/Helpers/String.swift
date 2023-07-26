extension String {
    static func placeholder(count: Int) -> String {
        String(Array(repeating: "X", count: count))
    }

    var isWhitespace: Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var trimmed: String? {
        let string = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return string.isEmpty ? nil : string
    }
}

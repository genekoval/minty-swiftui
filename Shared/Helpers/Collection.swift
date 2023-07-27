extension Collection {
    func countOf(type: String, plural: String? = nil) -> String {
        self.count.asCountOf(type, plural: plural)
    }
}

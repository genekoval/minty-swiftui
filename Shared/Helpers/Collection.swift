import Foundation

extension Collection {
    func countOf(type: String, plural: String? = nil) -> String {
        let countFormatted = NumberFormatter.localizedString(
            from: NSNumber(value: self.count),
            number: .decimal
        )

        let suffix = self.count == 1 ? type : (plural ?? "\(type)s")

        return "\(countFormatted) \(suffix)"
    }
}

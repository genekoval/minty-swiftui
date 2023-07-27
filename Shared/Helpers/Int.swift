import Foundation

extension Int {
    func asCountOf(_ unit: String, plural: String? = nil) -> String {
        let formatted = NumberFormatter.localizedString(
            from: NSNumber(value: self),
            number: .decimal
        )

        let suffix = self == 1 ? unit : (plural ?? "\(unit)s")

        return "\(formatted) \(suffix)"
    }
}

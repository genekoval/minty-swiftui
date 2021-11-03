import Foundation

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()

    formatter.dateStyle = .long
    formatter.timeStyle = .medium

    return formatter
}()

private let relativeFullFormatter = RelativeDateTimeFormatter()
private let relativeShortFormatter: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()

    formatter.unitsStyle = .abbreviated

    return formatter
}()

enum RelativeDateTimeStyle {
    case full
    case short
}

extension Date {
    func relative(_ style: RelativeDateTimeStyle) -> String {
        let sinceNow = self.timeIntervalSinceNow
        if sinceNow > -1 { return "now" }

        let formatter: RelativeDateTimeFormatter = {
            switch style {
            case .full:
                return relativeFullFormatter
            case .short:
                return relativeShortFormatter
            }
        }()

        return formatter.localizedString(fromTimeInterval: sinceNow)
    }

    var string: String {
        dateFormatter.string(from: self)
    }
}

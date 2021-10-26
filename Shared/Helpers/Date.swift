import Foundation

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()

    formatter.dateStyle = .long
    formatter.timeStyle = .medium

    return formatter
}()

private let relativeDateTimeFormatter = RelativeDateTimeFormatter()

extension Date {
    var relative: String {
        let sinceNow = self.timeIntervalSinceNow
        if sinceNow > -1 { return "just now" }

        return relativeDateTimeFormatter.localizedString(
            fromTimeInterval: sinceNow
        )
    }

    var string: String {
        dateFormatter.string(from: self)
    }
}

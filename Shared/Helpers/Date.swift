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
        relativeDateTimeFormatter.localizedString(for: self, relativeTo: Date())
    }

    var string: String {
        dateFormatter.string(from: self)
    }
}

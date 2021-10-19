import Foundation

private let iso8601DateFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()

    formatter.formatOptions = [
        .withInternetDateTime,
        .withFractionalSeconds,
        .withSpaceBetweenDateAndTime
    ]

    return formatter
}()

extension Date {
    init(from string: String) {
        self = iso8601DateFormatter.date(from: string)!
    }
}

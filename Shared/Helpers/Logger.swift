import os
import Foundation

let defaultLog = Logger()

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "MintyUI"

    static let settings = Logger(subsystem: subsystem, category: "settings")
}

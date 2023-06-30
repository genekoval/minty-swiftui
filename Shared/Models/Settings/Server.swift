import Foundation

private let portFormatter: NumberFormatter = {
    let formatter = NumberFormatter()

    formatter.numberStyle = .none
    formatter.groupingSeparator = ""

    return formatter
}()

struct Server: Codable, Identifiable, Equatable {
    var host = ""
    var port: UInt16 = 0

    var description: String {
        "\(host):\(portString)"
    }

    var id: String {
        description
    }

    var portString: String {
        get {
            port == 0 ? "" : portFormatter.string(from: NSNumber(value: port))!
        }
        set {
            if let value = portFormatter.number(from: newValue) {
                port = value.uint16Value
            }
            else {
                port = 0
            }
        }
    }
}

import SwiftUI

enum Status {
    case ok
    case error

    fileprivate var color: Color {
        switch self {
        case .ok:
            return .green
        case .error:
            return .red
        }
    }

    fileprivate var symbol: String {
        switch self {
        case .ok:
            return "checkmark.circle"
        case .error:
            return "xmark.octagon"
        }
    }
}

struct StatusIcon: View {
    private let status: Status

    var body: some View {
        Image(systemName: status.symbol)
            .foregroundColor(status.color)
            .symbolVariant(.fill)
    }

    init(_ status: Status) {
        self.status = status
    }
}

extension Label {
    init(_ title: String, status: Status) where
        Title == Text,
        Icon == StatusIcon
    {
        self.init {
            Text(title)
        } icon: {
            StatusIcon(status)
        }
    }
}

struct StatusIcon_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StatusIcon(.ok)
            StatusIcon(.error)
        }
    }
}

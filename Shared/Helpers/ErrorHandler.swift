import Combine
import Foundation
import Minty

struct ErrorAlert: Identifiable {
    var id = UUID()
    var message: String
    var dismissAction: (() -> Void)?
}

class ErrorHandler: ObservableObject {
    @Published var currentAlert: ErrorAlert?
    @Published var didError = false

    func handle(error: Error, dismissAction: (() -> Void)? = nil) {
        var alertMessage: String

        switch error {
        case MintyError.unspecified(let message):
            alertMessage = message
        default:
            alertMessage = error.localizedDescription
        }

        defaultLog.error("\(alertMessage)")

        currentAlert = ErrorAlert(
            message: alertMessage,
            dismissAction: dismissAction
        )

        didError = true
    }

    func handle(
        action: () throws -> Void,
        dismissAction: (() -> Void)? = nil
    ) {
        do {
            try action()
        }
        catch {
            handle(error: error, dismissAction: dismissAction)
        }
    }
}

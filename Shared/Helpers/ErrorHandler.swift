import os
import Combine
import Foundation
import Minty

struct ErrorAlert: Identifiable {
    var id = UUID()
    var message: String
    var dismissAction: (() -> Void)?
}

@MainActor
class ErrorHandler: ObservableObject {
    @Published var currentAlert: ErrorAlert?
    @Published var didError = false

    func handle(error: Error, dismissAction: (() -> Void)? = nil) {
        guard !Task.isCancelled else {
            Logger.handler.debug("Task cancelled")
            return
        }

        var alertMessage: String

        switch error {
        case MintyError.unspecified(let message):
            alertMessage = message
        case MintyError.internalError:
            alertMessage = "Internal server error."
        case MintyError.invalidData(let message):
            alertMessage = message
        case MintyError.notFound(let message):
            alertMessage = message
        default:
            alertMessage = error.localizedDescription
        }

        Logger.handler.error("\(error)")

        currentAlert = ErrorAlert(
            message: alertMessage,
            dismissAction: dismissAction
        )

        didError = true
    }

    func handle(
        action: @escaping () async throws -> Void,
        dismissAction: (() -> Void)? = nil
    ) {
        Task {
            do {
                try await action()
            }
            catch {
                handle(error: error, dismissAction: dismissAction)
            }
        }
    }
}

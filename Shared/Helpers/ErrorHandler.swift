import os
import Combine
import Foundation
import Minty

struct ErrorAlert: Identifiable {
    var id = UUID()
    var title: String?
    var message: String
    var dismissAction: (() -> Void)?
}

@MainActor
class ErrorHandler: ObservableObject {
    @Published var currentAlert: ErrorAlert?
    @Published var didError = false

    func present(
        _ title: String? = nil,
        message: String,
        dismissAction: (() -> Void)? = nil
    ) {
        currentAlert = ErrorAlert(
            title: title,
            message: message,
            dismissAction: dismissAction
        )

        didError = true
    }

    func handle(
        error: Error,
        title: String? = nil,
        dismissAction: (() -> Void)? = nil
    ) {
        guard !Task.isCancelled else {
            Logger.handler.debug("Task cancelled")
            return
        }

        var alertMessage: String

        switch error {
        case MintyError.other(let message):
            alertMessage = message
        case MintyError.serverError:
            alertMessage = "Internal server error."
        case MintyError.invalidData(let message):
            alertMessage = message
        case MintyError.notFound(let entity, let id):
            alertMessage =
                "\(entity.capitalized) with ID '\(id)' does not exist."
        default:
            alertMessage = error.localizedDescription
        }

        Logger.handler.error("\(error)")
        present(title, message: alertMessage, dismissAction: dismissAction)
    }

    func handle(
        action: @escaping () async throws -> Void,
        title: String? = nil,
        dismissAction: (() -> Void)? = nil
    ) {
        Task {
            do {
                try await action()
            }
            catch {
                handle(error: error, title: title, dismissAction: dismissAction)
            }
        }
    }
}

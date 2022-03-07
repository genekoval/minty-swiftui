import SwiftUI

private struct AlertErrorHandler: ViewModifier {
    @StateObject var errorHandler = ErrorHandler()

    func body(content: Content) -> some View {
        content
            .environmentObject(errorHandler)
            .alert(
                "Error",
                isPresented: $errorHandler.didError,
                presenting: errorHandler.currentAlert
            ) { currentAlert in
                Button("OK") {
                    currentAlert.dismissAction?()
                }
            } message: { currentAlert in
                Text(currentAlert.message)
            }
    }
}

extension View {
    func withErrorHandling() -> some View {
        modifier(AlertErrorHandler())
    }
}

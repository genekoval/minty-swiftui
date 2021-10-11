import SwiftUI

private let resetWarning = """
This will restore the app to its original installation state.

All of this app's user settings and data will be erased.

This action cannot be undone.
"""

private let resetCompleteMessage = """
App settings and data have been reset to their original state.

Please restart the app.
"""

struct ResetButton: View {
    @State private var resetComplete = false
    @State private var showingResetComplete = false
    @State private var showingResetConfirmation = false

    let action: () -> Void

    var body: some View {
        Button("Reset") {
            if resetComplete {
                showingResetComplete = true
            }
            else {
                showingResetConfirmation = true
            }
        }
        .alert(
            Text("Reset this app?"),
            isPresented: $showingResetConfirmation
        ) {
            Button("Reset", role: .destructive) { reset() }
        } message: { Text(resetWarning) }
        .alert(
            Text("Reset Complete"),
            isPresented: $showingResetComplete
        ) {
            Button("OK") { }
        } message: { Text(resetCompleteMessage) }
    }

    private func reset() {
        action()
        resetComplete = true
        showingResetComplete = true
    }
}

struct ResetButton_Previews: PreviewProvider {
    static var previews: some View {
        ResetButton { }
    }
}

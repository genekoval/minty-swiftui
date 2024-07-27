import SwiftUI

struct DeleteUser: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var data: DataSource
    @EnvironmentObject private var errorHandler: ErrorHandler

    @ObservedObject var user: User

    @State private var confirmationPresented = false

    var body: some View {
        List {
            Section {
                Button("Delete Account") {
                    confirmationPresented = true
                }
            } footer: {
                Text(footer)
            }
        }
        .navigationTitle("Delete Account")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Delete your account?",
            isPresented: $confirmationPresented,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive, action: deleteUser)
            Button("Cancel", role: .cancel) {}
        } message: {
            VStack {
                Text("This action cannot be undone.")
            }
        }
    }

    private var footer: String {
"""
Your posts, tags, and comments will remain and be visible to others.
"""
    }

    private func deleteUser() {
        errorHandler.handle {
            try await data.deleteAccount()
            dismiss()
        }
    }
}

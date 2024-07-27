import SwiftUI

private let minimumLength = 8

private struct PasswordField: View {
    let title: String

    @Binding var text: String

    @State private var isSecure = true

    var body: some View {
        HStack {
            if isSecure {
                SecureField(title, text: $text)
            } else {
                TextField(title, text: $text)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }

            Group {
                Text("\(count)")

                Button(action: { isSecure.toggle() }) {
                    Image(systemName: isSecure ? "eye" : "eye.slash")
                        .symbolVariant(.fill)
                }
            }
            .foregroundColor(.secondary)
        }
    }

    private var count: Int {
        text.trimmed?.count ?? 0
    }
}

struct ChangePassword: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var data: DataSource
    @EnvironmentObject private var errorHandler: ErrorHandler

    @State private var password = ""
    @State private var task: Task<Void, Never>?

    var body: some View {
        Form {
            Section {
                PasswordField(title: "New Password", text: $password)
                    .disabled(busy)
                    .onSubmit(done)
                    .submitLabel(.done)
            } footer: {
                Text("Password must be at least \(minimumLength) characters.")
            }
        }
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if busy {
                ProgressView()
            } else {
                Button(action: done) {
                    Text("Done")
                        .bold()
                        .disabled(!isValidPassword)
                }
            }
        }
    }

    private var busy: Bool {
        task != nil
    }

    private var count: Int {
        password.trimmed?.count ?? 0
    }

    private var isValidPassword: Bool {
        count >= minimumLength
    }

    private func done() {
        guard let password = password.trimmed, isValidPassword else { return }

        task?.cancel()
        task = Task {
            defer { task = nil }

            do {
                try await data.changePassword(to: password)
                dismiss()
            } catch {
                errorHandler.handle(error: error)
            }
        }
    }
}

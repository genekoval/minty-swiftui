import SwiftUI

struct ChangeEmail: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var data: DataSource
    @EnvironmentObject private var errorHandler: ErrorHandler

    @State private var email = ""
    @State private var task: Task<Void, Never>?

    var body: some View {
        Form {
            TextField("New Email Address", text: $email)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .disabled(busy)
                .onSubmit(done)
                .submitLabel(.done)
        }
        .navigationTitle("Change Email")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if busy {
                ProgressView()
            } else {
                Button(action: done) {
                    Text("Done")
                        .bold()
                        .disabled(email.trimmed == nil)
                }
            }
        }
    }

    private var busy: Bool {
        task != nil
    }

    private func done() {
        guard let email = email.trimmed else { return }

        task?.cancel()
        task = Task {
            defer { task = nil }

            do {
                try await data.changeEmail(to: email)
                dismiss()
            } catch {
                errorHandler.handle(error: error)
            }
        }
    }
}

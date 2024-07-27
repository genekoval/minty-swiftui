import Minty
import SwiftUI

struct AuthenticationView: View {
    @Environment(\.dismiss) private var defaultDismiss

    @EnvironmentObject private var data: DataSource
    @EnvironmentObject private var errorHandler: ErrorHandler

    @State private var createAccount = false
    @State private var email = ""
    @State private var password = ""
    @State private var task: Task<Void, Never>?
    @State private var username = ""

    let dismiss: DismissAction?

    var body: some View {
        PaddedScrollView {
            VStack(spacing: 40) {
                if let url = data.url {
                    VStack {
                        Text(
                            createAccount ?
                            "Create an account at" : "Sign in to"
                        )
                            .bold()
                            .font(.title)

                        Link(destination: url, label: {
                            Text("\(url)")
                                .font(.title2)
                        })
                    }
                }

                VStack {
                    if createAccount {
                        TextField("Username", text: $username)
                        Divider()
                    }

                    TextField("Email", text: $email)
                    Divider()
                    SecureField("Password", text: $password)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10.0)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .disabled(authenticating)

                HStack {
                    Text(
                        createAccount ?
                        "Already have an account?" :
                        "Creating a new account?"
                    )
                    Button(action: {
                        withAnimation {
                            createAccount.toggle()
                        }
                    }) {
                        Text(
                            createAccount ?
                            "Sign In" : "Register"
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
        .toolbar {
            if authenticating {
                ProgressView()
            } else {
                Button(action: createAccount ? register : authenticate) {
                    Text(createAccount ? "Register" : "Sign In")
                }
            }
        }
    }

    private var authenticating: Bool {
        task != nil
    }

    init(dismiss: DismissAction? = nil) {
        self.dismiss = dismiss
    }

    private func authenticate() {
        task = Task {
            defer { task = nil }

            do {
                let login = Login(email: email, password: password)
                try await data.authenticate(login)

                if let dismiss {
                    dismiss()
                } else {
                    defaultDismiss()
                }
            } catch MintyError.unauthenticated(_) {
                errorHandler.present(
                    "Verification Failed",
                    message: "Your email or password is incorrect."
                )
            } catch {
                errorHandler.handle(error: error)
            }
        }
    }

    private func register() {
        task = Task {
            defer { task = nil }

            do {
                let info = SignUp(
                    username: username,
                    email: email,
                    password: password
                )

                try await data.register(info)

                if let dismiss {
                    dismiss()
                } else {
                    defaultDismiss()
                }
            } catch {
                errorHandler.handle(error: error)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AuthenticationView()
    }
}

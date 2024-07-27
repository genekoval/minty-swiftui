import SwiftUI

struct UserView: View {
    @EnvironmentObject private var data: DataSource
    @EnvironmentObject private var errorHandler: ErrorHandler

    @State private var task: Task<Void, Never>?
    @State private var deletePresented = false

    var body: some View {
        NavigationStack {
            if let user = data.user {
                List {
                    Section {
                        NavigationLink(destination: UserHost(user: user)) {
                            Label("Profile", systemImage: "person.text.rectangle")
                        }

                        DraftsLink(user: user)
                    }

                    Section {
                        NavigationLink(destination: ChangeEmail()) {
                            Label(
                                "Change Email Address",
                                systemImage: "envelope"
                            )
                        }

                        NavigationLink(destination: ChangePassword()) {
                            Label("Change Password", systemImage: "key")
                        }
                    }

                    Section {
                        Button(role: .destructive, action: signOut) {
                            Text("Sign Out")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }

                    Section {
                        Button(
                            role: .destructive,
                            action: { deletePresented = true }
                        ) {
                            Text("Delete Account")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
                .disabled(busy)
                .navigationTitle("Account")
                .toolbar { SwitchAccountsButton() }
                .navigationDestination(isPresented: $deletePresented) {
                    DeleteUser(user: user)
                }
            } else if !data.settings.otherAccounts.isEmpty {
                SwitchAccounts(dismissable: false)
                    .navigationTitle("Select Account")
            } else {
                AuthenticationView()
            }
        }
    }

    private var busy: Bool {
        task != nil
    }

    private func signOut() {
        task = Task {
            defer { task = nil }

            do {
                try await data.signOut(keepingPassword: false)
            }
            catch {
                errorHandler.handle(error: error)
            }
        }
    }
}

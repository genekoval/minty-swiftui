import SwiftUI

private struct AccountView: View {
    let account: Account

    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40)
                .foregroundColor(.secondary)

            VStack(alignment: .leading) {
                Text(account.name)
                Text(account.email)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct SwitchAccounts: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var data: DataSource
    @EnvironmentObject private var errorHandler: ErrorHandler

    let dismissable: Bool

    var body: some View {
        List {
            ForEach(data.settings.otherAccounts, id: \.0) { (id, account) in
                Button(action: { switchAccount(to: id) }) {
                    AccountView(account: account)
                }
            }
            .buttonStyle(.plain)

            if data.user != nil {
                Button(action: { switchAccount(to: nil) }) {
                    Label(
                        "Browse as a guest",
                        systemImage: "person.crop.circle.dashed"
                    )
                }
                .buttonStyle(.plain)
            }

            NavigationLink(destination: AuthenticationView(
                dismiss: dismissable ? dismiss : nil
            )) {
                Label("Add a new account", systemImage: "plus")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if dismissable {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    init(dismissable: Bool = true) {
        self.dismissable = dismissable
    }

    private func switchAccount(to id: UUID?) {
        errorHandler.handle {
            try await data.switchAccount(to: id)
            dismiss()

        }
    }
}

private struct SwitchAccountsModifier: ViewModifier {
    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        content.sheet(isPresented: $isPresented) {
            NavigationStack {
                SwitchAccounts()
                    .navigationTitle("Switch Accounts")
            }
        }
    }
}

extension View {
    func switchAccounts(isPresented: Binding<Bool>) -> some View {
        modifier(SwitchAccountsModifier(isPresented: isPresented))
    }
}

struct SwitchAccountsButton: View {
    @State private var isPresented = false

    var body: some View {
        Button(action: { isPresented = true }) {
            Image(systemName: "person.and.arrow.left.and.arrow.right")
        }
        .switchAccounts(isPresented: $isPresented)
    }
}

#Preview {
    List {
        AccountView(account: Account(
            email: "hello@example.com",
            name: "Hello World"
        ))
    }
}

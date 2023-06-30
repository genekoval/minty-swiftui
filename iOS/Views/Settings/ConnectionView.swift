import SwiftUI

private struct ConnectionView: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var settings: SettingsViewModel

    @State private var server = Server()

    var body: some View {
        NavigationStack {
            Form {
                HStack(spacing: 20) {
                    Text("Host")
                    TextField("example.com", text: $server.host)
                }

                HStack(spacing: 20) {
                    Text("Port")
                    TextField("443", text: $server.portString)
                }
            }
            .autocorrectionDisabled()
            .autocapitalization(.none)
            .navigationTitle("Connect to Server")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: connect) {
                        Text("Connect")
                            .bold()
                            .disabled(
                                server.host.isEmpty ||
                                server.port == 0
                            )
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    DismissButton()
                }
            }
        }
    }

    private func connect() {
        settings.connect(to: server)
        dismiss()
    }
}

private struct ConnectionViewModifier: ViewModifier {
    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                ConnectionView()
            }
    }
}

extension View {
    func connectionView(isPresented: Binding<Bool>) -> some View {
        modifier(ConnectionViewModifier(isPresented: isPresented))
    }
}

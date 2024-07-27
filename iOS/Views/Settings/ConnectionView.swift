import SwiftUI

private struct ConnectionView: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var data: DataSource

    @State private var server = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField(
                    "Server URL",
                    text: $server,
                    prompt: Text(verbatim: "https://example.com")
                )
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
                            .disabled(server.isEmpty)
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    DismissButton()
                }
            }
        }
    }

    private func connect() {
        guard let url = URL(string: server) else { return }
        
        data.connect(to: url)
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

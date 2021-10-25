import Minty
import SwiftUI

struct ConnectionModal: View {
    let closable: Bool
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var settings: SettingsViewModel
    @State private var server = Server(host: "", port: 0)

    var body: some View {
        VStack {
            if closable {
                HStack {
                    Button("Cancel") { dismiss() }
                    Spacer()
                }
            }

            Spacer()

            Image(systemName: "server.rack")
                .font(.title)
                .padding()
            Text("Connect to a Server")
                .font(.title)

            Spacer()

            ServerEditor(server: $server)

            Spacer()

            Button("Connect") { connect() }
                .tint(.green)
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
        }
        .padding()
    }

    private func connect() {
        settings.server = server
        dismiss()
    }

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct ConnectionModal_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionModal(closable: true)
            .environmentObject(SettingsViewModel())
    }
}

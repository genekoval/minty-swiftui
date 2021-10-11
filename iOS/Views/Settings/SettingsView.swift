import Minty
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var app: AppState
    @State private var showingConnectionModal = false

    var body: some View {
        NavigationView {
            List {
                if let server = app.settings.server {
                    Section(header: Text("Server")) {
                        NavigationLink(destination: ServerDetail(
                            title: "Current Server",
                            server: server,
                            info: try? app.repo?.getServerInfo()
                        )) {
                            VStack {
                                Text("Current Server")
                                Text("\(server.host):\(server.portString)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Button("New Server") { showingConnectionModal.toggle() }
                    }
                }

                Section {
                    NavigationLink(destination: AboutView()) { Text("About") }
                }

                Section(header: Text("Troubleshoot")) {
                    ResetButton { app.settings.reset() }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingConnectionModal) {
                ConnectionModal(closable: true)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppState())
    }
}

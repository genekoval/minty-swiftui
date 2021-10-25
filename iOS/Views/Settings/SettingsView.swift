import Minty
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var data: DataSource
    @EnvironmentObject var objects: ObjectSource
    @EnvironmentObject var settings: SettingsViewModel
    @State private var showingConnectionModal = false

    var body: some View {
        NavigationView {
            List {
                if let server = settings.server {
                    Section(header: Text("Server")) {
                        NavigationLink(destination: ServerDetail(
                            title: "Current Server",
                            server: server,
                            info: try? data.repo?.getServerInfo()
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

                Section(header: Text("Cache")) {
                    HStack {
                        Text("Size")
                        Spacer()
                        Text(objects.cacheSize.asByteCount)
                            .foregroundColor(.secondary)
                    }


                    if !objects.cachedObjects.isEmpty {
                        NavigationLink(destination: CacheList()) {
                            Text("Inspect")
                        }

                        Button("Clear Cache") { objects.clearCache() }
                    }
                }

                Section {
                    NavigationLink(destination: AboutView()) { Text("About") }
                }

                Section(header: Text("Troubleshoot")) {
                    ResetButton { reset() }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingConnectionModal) {
                ConnectionModal(closable: true)
            }
        }
    }

    private func reset() {
        objects.clearCache()
        settings.reset()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(DataSource.preview)
            .environmentObject(ObjectSource.preview)
            .environmentObject(SettingsViewModel())
    }
}

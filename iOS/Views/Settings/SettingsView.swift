import Minty
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var data: DataSource
    @EnvironmentObject var errorHandler: ErrorHandler
    @EnvironmentObject var objects: ObjectSource
    @EnvironmentObject var settings: SettingsViewModel

    @State private var refreshing = false
    @State private var showingConnectionModal = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Server")) {
                    if let server = settings.server {
                        NavigationLink(destination: ServerDetail(
                            title: "Current Server",
                            server: server
                        )) {
                            VStack {
                                Text("Current Server")
                                Text("\(server.host):\(server.portString)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Button("New Server") { showingConnectionModal.toggle() }
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

                        Button("Clear Cache") { clearCache() }
                    }
                }

                Section(header: Text("Help")) {
                    NavigationLink(destination: AboutView()) { Text("About") }
                    ResetButton { reset() }
                }
            }
            .playerSpacing()
            .navigationTitle("Settings")
            .sheet(isPresented: $showingConnectionModal) {
                ConnectionModal(closable: true)
            }
            .onAppear { refreshCache() }
        }
    }

    private func clearCache() {
        errorHandler.handle { try objects.clearCache() }
    }

    private func refreshCache() {
        if !refreshing && objects.needsRefresh {
            refreshing = true

            Task {
                await objects.refresh()
                await MainActor.run { refreshing = false }
            }
        }
    }

    private func reset() {
        clearCache()
        settings.reset()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .withErrorHandling()
            .environmentObject(DataSource.preview)
            .environmentObject(ObjectSource.preview)
            .environmentObject(SettingsViewModel())
    }
}

import Minty
import SwiftUI

private func info(key: String) -> String? {
    Bundle.main.object(forInfoDictionaryKey: key) as? String
}

private func connect(
    server: Server
) async throws -> (MintyRepo, ServerMetadata) {
    try await ZiplineClient.create(host: server.host, port: server.port)
}

@main
struct MintyApp: App {
    static var build: String? {
        info(key: "CFBundleVersion")
    }

    static var version: String? {
        info(key: "CFBundleShortVersionString")
    }

    @StateObject private var data = DataSource(connect: connect)
    @StateObject private var objects: ObjectSource = ObjectCache()
    @StateObject private var overlay = Overlay()
    @StateObject private var player = MediaPlayer()
    @StateObject private var settings = SettingsViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .withErrorHandling()
                .environmentObject(data)
                .environmentObject(objects)
                .environmentObject(overlay)
                .environmentObject(player)
                .environmentObject(settings)
        }
    }
}

import Minty
import SwiftUI

private func info(key: String) -> String? {
    Bundle.main.object(forInfoDictionaryKey: key) as? String
}

private func connect(server: Server) async throws -> MintyRepo {
    var components = URLComponents()
    components.scheme = "https"
    components.host = server.host
    components.port = Int(server.port)

    return try await HTTPClient(baseURL: components.url!)
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
    @StateObject private var user = CurrentUser()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .withErrorHandling()
                .environmentObject(data)
                .environmentObject(objects)
                .environmentObject(overlay)
                .environmentObject(player)
                .environmentObject(settings)
                .environmentObject(user)
        }
    }
}

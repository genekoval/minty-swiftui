import Minty
import SwiftUI

private func info(key: String) -> String? {
    Bundle.main.object(forInfoDictionaryKey: key) as? String
}

private func connect(to server: URL) async throws -> MintyRepo {
    guard let client = HTTPClient(baseURL: server) else {
        throw DisplayError("The server URL (\(server)) is invalid.")
    }

    return client
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

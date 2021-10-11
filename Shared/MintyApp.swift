import Minty
import SwiftUI

final class AppState: ObservableObject {
    @Published var repo: MintyRepo?
    @Published var settings = SettingsViewModel()

    func connect() {
        guard let server = settings.server else { return }

        repo = try? ZiplineClient(
            host: server.host,
            port: server.port
        )
    }
}

@main
struct MintyApp: App {
    static var version: String? {
        Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString"
        ) as? String
    }

    @StateObject private var state: AppState = {
        let value = AppState()
        value.connect()
        return value
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(state)
        }
    }
}

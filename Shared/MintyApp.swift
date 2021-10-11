import Minty
import SwiftUI

private func info(key: String) -> String? {
    Bundle.main.object(forInfoDictionaryKey: key) as? String
}

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
    static var build: String? {
        info(key: "CFBundleVersion")
    }

    static var version: String? {
        info(key: "CFBundleShortVersionString")
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

import Minty
import SwiftUI

private func info(key: String) -> String? {
    Bundle.main.object(forInfoDictionaryKey: key) as? String
}

@main
struct MintyApp: App {
    static var build: String? {
        info(key: "CFBundleVersion")
    }

    static var version: String? {
        info(key: "CFBundleShortVersionString")
    }

    @StateObject private var data = DataSource()
    @StateObject private var objects: ObjectSource = ObjectCache()
    @StateObject private var overlay = Overlay()
    @StateObject private var player = MediaPlayer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .withErrorHandling()
                .environmentObject(data)
                .environmentObject(objects)
                .environmentObject(overlay)
                .environmentObject(player)
        }
    }
}

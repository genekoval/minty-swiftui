import SwiftUI

private enum Tab {
    case search
    case settings
}

struct AppShell: View {
    @EnvironmentObject private var player: MediaPlayer

    @State private var playerFrame: CGRect = .zero
    @State private var selection: Tab = .search

    var body: some View {
        TabView(selection: $selection) {
            Group {
                search
                settings
            }
            .toolbarBackground(MiniPlayer.background, for: .tabBar)
            .toolbarBackground(
                player.visible ? .visible : .automatic,
                for: .tabBar
            )
        }
        .onPreferenceChange(Size.self) { size in
            playerFrame = size.last ?? .zero
        }
        .overlay(alignment: .bottom) {
            MediaOverlay(frame: playerFrame)
        }
    }

    @ViewBuilder
    private var search: some View {
        TabFrame {
            SearchHome()
        }
        .tabItem {
            Label("Search", systemImage: "magnifyingglass")
        }
        .tag(Tab.search)
    }

    @ViewBuilder
    private var settings: some View {
        TabFrame {
            SettingsView()
        }
        .tabItem {
            Label("Settings", systemImage: "gear")
        }
        .tag(Tab.settings)
    }
}

struct AppShell_Previews: PreviewProvider {
    static var previews: some View {
        AppShell()
            .environmentObject(DataSource.preview)
            .environmentObject(MediaPlayer.preview)
            .environmentObject(ObjectSource.preview)
            .environmentObject(SettingsViewModel())
    }
}

import SwiftUI

private enum Tab {
    case home
    case search
    case settings
    case user
}

struct AppShell: View {
    @EnvironmentObject private var player: MediaPlayer

    @State private var playerFrame: CGRect = .zero
    @State private var selection: Tab = .home

    var body: some View {
        TabView(selection: $selection) {
            Group {
                home
                search
                user
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
    private var home: some View {
        TabFrame {
            Home()
        }
        .tabItem {
            Label("Home", systemImage: "house")
        }
        .tag(Tab.home)
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

    @ViewBuilder
    private var user: some View {
        TabFrame {
            UserView()
        }
        .tabItem {
            Label("User", systemImage: "person.crop.circle")
        }
        .tag(Tab.user)
    }
}

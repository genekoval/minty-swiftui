import SwiftUI

private enum Tab {
    case search
    case settings
}

struct AppShell: View {
    @State private var selection: Tab = .search

    var body: some View {
        TabView(selection: $selection) {
            SearchHome()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(Tab.search)
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(Tab.settings)
        }
    }
}

struct AppShell_Previews: PreviewProvider {
    static var previews: some View {
        AppShell()
            .environmentObject(AppState())
    }
}

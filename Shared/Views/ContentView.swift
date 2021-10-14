import SwiftUI

struct ContentView: View {
    @EnvironmentObject var app: AppState
    @State private var showingConnectionModal = false

    var body: some View {
        AppShell()
            .fullScreenCover(isPresented: $showingConnectionModal) {
                ConnectionModal(closable: false)
            }
            .onAppear { showingConnectionModal = app.settings.server == nil }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var data: DataSource
    @EnvironmentObject var errorHandler: ErrorHandler
    @EnvironmentObject var objects: ObjectSource
    @EnvironmentObject var player: MediaPlayer
    @EnvironmentObject var settings: SettingsViewModel

    @State private var showingConnectionModal = false

    var body: some View {
        AppShell()
            .fullScreenCover(isPresented: $showingConnectionModal) {
                ConnectionModal(closable: false)
            }
            .viewerOverlay()
            .onAppear {
                setUpEnvironment()
                showingConnectionModal = settings.server == nil
            }
    }

    private func onFailedConnection(error: Error) {
        errorHandler.handle(error: error)
    }

    private func setUpEnvironment() {
        player.errorHandler = errorHandler
        player.source = objects
        objects.dataSource = data
        data.onFailedConnection = onFailedConnection
        data.observe(server: settings.$server)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .withErrorHandling()
            .environmentObject(DataSource.preview)
            .environmentObject(MediaPlayer.preview)
            .environmentObject(ObjectSource.preview)
            .environmentObject(Overlay())
            .environmentObject(SettingsViewModel())
    }
}

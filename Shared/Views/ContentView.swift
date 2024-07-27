import SwiftUI

struct ContentView: View {
    @EnvironmentObject var data: DataSource
    @EnvironmentObject var errorHandler: ErrorHandler
    @EnvironmentObject var objects: ObjectSource
    @EnvironmentObject var player: MediaPlayer

    var body: some View {
        AppShell()
            .viewerOverlay()
            .onAppear {
                setUpEnvironment()
            }
    }

    private func setUpEnvironment() {
        player.errorHandler = errorHandler
        player.source = objects
        objects.dataSource = data
    }
}

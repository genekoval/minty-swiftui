import SwiftUI

struct ContentView: View {
    @EnvironmentObject var data: DataSource
    @EnvironmentObject var objects: ObjectSource
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

    private func setUpEnvironment() {
        objects.dataSource = data
        data.observe(server: settings.$server)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DataSource.preview)
            .environmentObject(ObjectSource.preview)
            .environmentObject(Overlay())
            .environmentObject(SettingsViewModel())
    }
}

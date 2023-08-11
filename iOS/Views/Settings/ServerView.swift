import SwiftUI

struct ServerView: View {
    @EnvironmentObject private var data: DataSource
    @EnvironmentObject private var settings: SettingsViewModel

    @State private var showingConnectionView = false

    var body: some View {
        List {
            if let server = settings.server {
                Section {
                    NavigationLink(destination: ServerDetail(
                        title: "Current Server",
                        server: server
                    )) {
                        Label {
                            Text(server.description)
                        } icon: {
                            if let status = data.server {
                                switch status {
                                case .connected:
                                    StatusIcon(.ok)
                                case .error:
                                    StatusIcon(.error)
                                }
                            }
                            else {
                                EmptyView()
                            }
                        }
                    }
                }
            }

            Button("Connect to a server...") {
                showingConnectionView = true
            }

            if !settings.serverList.isEmpty {
                Section(header: Text("Recent Servers")) {
                    ForEach(settings.serverList, id: \.self) { server in
                        NavigationLink(destination: ServerDetail(
                            title: "Recent Server",
                            server: server
                        )) {
                            Text(server.description)
                        }
                    }
                    .onDelete {
                        settings.serverList.remove(atOffsets: $0)
                    }
                }
            }
        }
        .playerSpacing()
        .navigationTitle("Server")
        .navigationBarTitleDisplayMode(.inline)
        .connectionView(isPresented: $showingConnectionView)
    }
}

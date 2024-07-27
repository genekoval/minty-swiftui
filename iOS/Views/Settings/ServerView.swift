import SwiftUI

struct ServerView: View {
    @EnvironmentObject private var data: DataSource

    @State private var showingConnectionView = false

    var body: some View {
        List {
            if let server = data.settings.server {
                Section {
                    NavigationLink(destination: ServerDetail(
                        title: "Current Server",
                        server: server.url
                    )) {
                        Label {
                            Text(server.url.description)
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

            if !data.settings.recentServers.isEmpty {
                Section(header: Text("Recent Servers")) {
                    ForEach(data.settings.recentServers, id: \.self) { server in
                        NavigationLink(destination: ServerDetail(
                            title: "Recent Server",
                            server: server
                        )) {
                            Text(server.description)
                        }
                    }
                    .onDelete {
                        let keys = Array(data.settings.servers.keys)

                        for i in $0 {
                            let key = keys[i]
                            data.settings.servers.removeValue(forKey: key)
                        }
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

import Minty
import SwiftUI

struct ServerDetail: View {
    @EnvironmentObject var data: DataSource
    @EnvironmentObject var settings: SettingsViewModel

    let title: String
    let server: Server

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Host")
                    Spacer()
                    Text(server.host)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Port")
                    Spacer()
                    Text(server.portString)
                        .foregroundColor(.secondary)
                }
            }

            if let info = data.server {
                switch (info) {
                case .connected(let metadata):
                    Section {
                        HStack {
                            Text("Server Version")
                            Spacer()
                            Text(metadata.version)
                                .foregroundColor(.secondary)
                        }
                    }
                case .error(let message, let detail):
                    Section {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                            Text(message)
                        }
                        Text(detail)
                            .foregroundColor(.secondary)
                    }

                    Section {
                        Button("Retry") {
                            settings.server = settings.server
                        }
                    }
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ServerDetail_Previews: PreviewProvider {
    static var previews: some View {
        ServerDetail(
            title: "Server",
            server: Server(host: "127.0.0.1", port: 3000)
        )
        .environmentObject(DataSource.preview)
        .environmentObject(SettingsViewModel())
    }
}

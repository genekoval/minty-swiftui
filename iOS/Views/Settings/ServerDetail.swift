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

            if server == settings.server {
                if data.connecting {
                    Section {
                        Label {
                            Text("Connecting...")
                        } icon: {
                            ProgressView()
                        }
                    }
                }
                else if let info = data.server {
                    switch info {
                    case .connected(let metadata):
                        Section {
                            Label("Connected", status: .ok)
                        }

                        Section {
                            Text("Server Version")
                                .badge(metadata.version)
                        }
                    case .error(let message, let detail):
                        Section {
                            Label(message, status: .error)

                            Text(detail)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if server != settings.server || connectionError {
                Button(action: connect) {
                    Text("Connect")
                        .bold()
                }
            }
        }
    }

    private var connectionError: Bool {
        guard let info = data.server else { return false }

        switch info {
        case .error:
            return true
        default:
            return false
        }
    }

    private func connect() {
        settings.connect(to: server)
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

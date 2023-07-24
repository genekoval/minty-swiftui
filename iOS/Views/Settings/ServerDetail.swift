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
                    case .connected(let version):
                        Section {
                            Label("Connected", status: .ok)
                        }

                        Section {
                            Text("Server Version")
                                .badge(version)
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

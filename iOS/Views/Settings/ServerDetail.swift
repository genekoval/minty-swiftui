import Minty
import SwiftUI

struct ServerDetail: View {
    @EnvironmentObject var data: DataSource

    let title: String
    let server: URL

    var body: some View {
        List {
            Text(server.absoluteString)
                .textSelection(.enabled)

            if server == data.settings.server?.url {
                if data.connecting {
                    Section(header: Text("Status")) {
                        Label {
                            Text("Connecting...")
                        } icon: {
                            ProgressView()
                        }
                    }
                }
                else if let info = data.server {
                    switch info {
                    case .connected(let about):
                        Section(header: Text("Status")) {
                            Label("Connected", status: .ok)
                        }

                        Section {
                            Text("Server Version")
                                .badge(about.version)
                        }
                    case .error(let message, let detail):
                        Section(header: Text("Status")) {
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
            if server != data.settings.server?.url || connectionError {
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
        data.settings.connect(to: server)
    }
}

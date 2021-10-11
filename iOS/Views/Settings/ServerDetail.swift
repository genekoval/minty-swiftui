import Minty
import SwiftUI

struct ServerDetail: View {
    let title: String
    let server: Server
    let info: ServerInfo?

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

            if let info = info {
                Section {
                    HStack {
                        Text("Server Version")
                        Spacer()
                        Text(info.version)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ServerDetail_Previews: PreviewProvider {
    private static let info: ServerInfo = {
        var info = ServerInfo()
        info.version = "0.1.0"
        return info
    }()

    static var previews: some View {
        ServerDetail(
            title: "Server",
            server: Server(host: "127.0.0.1", port: 3000),
            info: info
        )
    }
}

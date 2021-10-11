import SwiftUI

struct ServerEditor: View {
    @Binding var server: Server

    var body: some View {
        VStack(spacing: 30) {
            VStack(alignment: .leading) {
                Text("Host")
                    .bold()
                TextField("IP address or domain name", text: $server.host)
            }

            VStack(alignment: .leading) {
                Text("Port")
                    .bold()
                TextField("Port number", text: $server.portString)
            }
        }
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .padding(.horizontal)
        .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

struct ServerEditor_Previews: PreviewProvider {
    static var previews: some View {
        ServerEditor(server: .constant(Server(host: "", port: 0)))
    }
}

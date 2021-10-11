import SwiftUI

struct AboutView: View {
    var body: some View {
        List {
            if let version = MintyApp.version {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(version)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}

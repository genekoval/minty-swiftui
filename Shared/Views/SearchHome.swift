import SwiftUI

struct SearchHome: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: TagSearch()) {
                    HStack {
                        Image(systemName: "tag")
                        Text("Tags")
                    }
                }
            }
            .navigationTitle("Search")
        }
    }
}

struct SearchHome_Previews: PreviewProvider {
    static var previews: some View {
        SearchHome()
            .environmentObject(AppState())
    }
}

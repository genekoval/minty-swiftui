import SwiftUI

struct UserView: View {
    var body: some View {
        NavigationStack {
            List {
                DraftsLink()
            }
            .listStyle(.plain)
            .navigationTitle("User")
        }
    }
}

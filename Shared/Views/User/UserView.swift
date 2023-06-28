import SwiftUI

struct UserView: View {
    @StateObject private var drafts = PostQueryViewModel(
        visibility: .draft,
        searchNow: true
    )

    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: DraftsView(search: drafts)) {
                    Label("Drafts", systemImage: "doc")
                        .badge(drafts.total)
                }
            }
            .prepareSearch(drafts)
            .listStyle(.plain)
            .navigationTitle("User")
        }
    }
}

import SwiftUI

struct Home: View {
    @EnvironmentObject private var data: DataSource

    @StateObject private var search = PostQueryViewModel(searchNow: true)

    var body: some View {
        NavigationStack {
            PaddedScrollView {
                PostSearchResults(search: search, showResultCount: false)
            }
            .prepareSearch(search)
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(data.$repo) { _ in
                Task {
                    await search.newSearch()
                }
            }
            .refreshable {
                await search.newSearch()
            }
        }
    }
}

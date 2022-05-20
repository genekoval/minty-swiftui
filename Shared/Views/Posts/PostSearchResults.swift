import SwiftUI

struct PostSearchResults: View {
    @ObservedObject var search: PostQueryViewModel

    let showResultCount: Bool

    var body: some View {
        SearchResults(
            search: search,
            type: "Post",
            text: nil,
            showResultCount: showResultCount
        ) { post in
            NavigationLink(destination: PostDetail(post: post)) {
                VStack {
                    PostRow(post: post)
                    Divider()
                }
            }
        }
    }
}

struct PostSearchResults_Previews: PreviewProvider {
    private struct Preview: View {
        @StateObject private var search =
            PostQueryViewModel.preview(searchNow: true)

        var body: some View {
            NavigationView {
                ScrollView {
                    PostSearchResults(
                        search: search,
                        showResultCount: true
                    )
                }
                .navigationTitle("Search")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    static var previews: some View {
        Preview()
            .environmentObject(ObjectSource.preview)
    }
}

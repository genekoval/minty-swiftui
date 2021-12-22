import SwiftUI

struct PostSearchResults: View {
    @ObservedObject var search: PostQueryViewModel
    @ObservedObject var deleted: Deleted

    let showResultCount: Bool

    var body: some View {
        SearchResults(
            search: search,
            deleted: deleted,
            type: "Post",
            showResultCount: showResultCount
        ) { post in
            NavigationLink(destination: PostDetail(
                id: post.id,
                repo: search.repo,
                deleted: deleted,
                preview: post
            )) {
                PostRow(post: post.wrappedValue)
            }
        }
    }
}

struct PostSearchResults_Previews: PreviewProvider {
    private struct Preview: View {
        @StateObject private var search =
            PostQueryViewModel.preview(searchNow: true)
        @StateObject private var deleted = Deleted()

        var body: some View {
            NavigationView {
                ScrollView {
                    PostSearchResults(
                        search: search,
                        deleted: deleted,
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

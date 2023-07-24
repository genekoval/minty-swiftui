import SwiftUI

struct PostSearchResults: View {
    @ObservedObject var search: PostQueryViewModel

    let showResultCount: Bool

    var body: some View {
        SearchResults(
            search: search,
            type: "Post",
            showResultCount: showResultCount
        ) { post in
            NavigationLink(destination: PostHost(post: post)) {
                VStack {
                    PostRow(post: post)
                    Divider()
                }
            }
        }
    }
}

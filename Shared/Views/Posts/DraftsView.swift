import SwiftUI

struct DraftsView: View {
    @ObservedObject var search: PostQueryViewModel

    @State private var draft: PostViewModel?

    var body: some View {
        PaddedScrollView {
            PostSearchResults(search: search, showResultCount: true)
                .noResultsTitle("No Drafts")
                .noResultsText("Post drafts you create can be found here.")
        }
        .navigationTitle("Drafts")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { NewPostButton(draft: $draft, tag: nil) }
        .refreshable { await search.newSearch() }
    }
}

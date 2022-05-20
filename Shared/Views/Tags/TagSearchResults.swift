import SwiftUI

struct TagSearchResults: View {
    @ObservedObject var search: TagQueryViewModel

    var body: some View {
        SearchResults(
            search: search,
            type: "Tag",
            text: search.name,
            showResultCount: !search.name.isEmpty
        ) { tag in
            NavigationLink(destination: TagDetail(tag: tag)) {
                VStack {
                    TagRow(tag: tag)
                    Divider()
                }
                .padding(.horizontal)
            }
        }
    }
}

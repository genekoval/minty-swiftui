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
            NavigationLink(destination: TagDetail(
                tag: tag.wrappedValue,
                repo: search.repo
            )) {
                VStack {
                    TagRow(tag: tag.wrappedValue)
                    Divider()
                }
                .padding(.horizontal)
            }
        }
    }
}

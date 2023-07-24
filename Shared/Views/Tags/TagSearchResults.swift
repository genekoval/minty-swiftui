import SwiftUI

struct TagSearchBase<Content>: View where Content : View {
    @ObservedObject var search: TagQueryViewModel

    @ViewBuilder let content: (TagViewModel) -> Content

    var body: some View {
        SearchResults(
            search: search,
            type: "Tag",
            showResultCount: !name.isEmpty,
            content: content
        )
        .noResultsText("There were no results for “\(name)”. Try a new search.")
    }

    private var name: String {
        search.name.trimmingCharacters(in: .whitespaces)
    }
}

struct TagSearchResults: View {
    @ObservedObject var search: TagQueryViewModel

    var body: some View {
        TagSearchBase(search: search) { tag in
            VStack {
                TagRow(tag: tag)
                Divider()
            }
            .padding(.horizontal)
        }
    }
}

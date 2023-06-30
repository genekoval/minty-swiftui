import SwiftUI

struct TagSearchBase<Content>: View where Content : View {
    @ObservedObject var search: TagQueryViewModel

    @ViewBuilder let content: (TagViewModel) -> Content

    @State private var newTag: TagViewModel?

    var body: some View {
        SearchResults(
            search: search,
            type: "Tag",
            showResultCount: !name.isEmpty,
            content: content,
            sideContent: {
                NewTagButton(name: name, tag: $newTag)
            }
        )
        .noResultsText("There were no results for “\(name)”. Try a new search.")
        .onReceive(search.$name) { _ in newTag = nil }
    }

    private var name: String {
        search.name.trimmingCharacters(in: .whitespaces)
    }
}

struct TagSearchResults: View {
    @ObservedObject var search: TagQueryViewModel

    var body: some View {
        TagSearchBase(search: search) { tag in
            NavigationLink(destination: TagHost(tag: tag)) {
                VStack {
                    TagRow(tag: tag)
                    Divider()
                }
                .padding(.horizontal)
            }
        }
    }
}

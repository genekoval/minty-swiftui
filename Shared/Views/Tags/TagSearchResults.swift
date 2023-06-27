import SwiftUI

struct TagSearchResults: View {
    @ObservedObject var search: TagQueryViewModel

    @State private var newTag: TagViewModel?

    var body: some View {
        SearchResults(
            search: search,
            type: "Tag",
            text: name,
            showResultCount: !name.isEmpty
        ) { tag in
            NavigationLink(destination: TagHost(tag: tag)) {
                VStack {
                    TagRow(tag: tag)
                    Divider()
                }
                .padding(.horizontal)
            }
        } sideContent: {
            NewTagButton(name: name, tag: $newTag)
        }
        .onReceive(search.$name) { _ in newTag = nil }
    }

    private var name: String {
        search.name.trimmingCharacters(in: .whitespaces)
    }
}

import Minty
import SwiftUI

private typealias SortValue = PostQuery.Sort.SortValue

private struct SearchControls: View {
    @ObservedObject var search: PostQueryViewModel

    @FocusState private var searchFocused: Bool

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")

                    TextField(
                        "Search",
                        text: $search.text,
                        onCommit: {
                            search.query.text =
                                search.text.isEmpty ? nil : search.text
                        }
                    )
                    .focused($searchFocused)
                    .foregroundColor(.primary)

                    Button(action: {
                        search.text = ""
                        searchFocused = true
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .opacity(search.text.isEmpty ? 0 : 1)
                    }
                }
                .padding(EdgeInsets(
                    top: 8,
                    leading: 6,
                    bottom: 8,
                    trailing: 6
                ))
                .foregroundColor(.secondary)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10.0)

                if searchFocused {
                    Button(action: { searchFocused.toggle() }) {
                        Text("Cancel")
                            .foregroundColor(.accentColor)
                    }
                }
            }

            HStack {
                Button(action: { search.query.sort.order.toggle() }) {
                    Image(systemName:
                        "chevron.\(sortDirection).circle.fill"
                    )
                }

                .foregroundColor(.accentColor)

                Picker("Sort Value",  selection: $search.query.sort.value) {
                    Text("Date Created").tag(SortValue.dateCreated)
                    Text("Date Modified").tag(SortValue.dateModified)
                    Text("Relevance").tag(SortValue.relevance)
                    Text("Title").tag(SortValue.title)
                }

                Spacer()

                TagSelectButton(tags: $search.tags, repo: search.repo)
            }
        }
    }

    private var sortDirection: String {
        search.query.sort.order == .ascending ? "up" : "down"
    }
}

struct PostSearch: View {
    @ObservedObject var search: PostQueryViewModel
    @ObservedObject var deleted: Deleted

    var body: some View {
        ScrollView {
            VStack {
                SearchControls(search: search)
                    .padding(.horizontal)

                PostSearchResults(
                    search: search,
                    deleted: deleted,
                    showResultCount: true
                )
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PostSearch_Previews: PreviewProvider {
    @StateObject private static var search = PostQueryViewModel.preview()
    @StateObject private static var deleted = Deleted()

    static var previews: some View {
        NavigationView {
            PostSearch(search: search, deleted: deleted)
        }
        .padding(.horizontal)
        .environmentObject(DataSource.preview)
        .environmentObject(ObjectSource.preview)
    }
}

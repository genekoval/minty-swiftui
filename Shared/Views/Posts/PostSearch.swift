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
                        onCommit: { search.newSearch() }
                    )
                    .focused($searchFocused)
                    .foregroundColor(.primary)
                    .task {
                        if !search.initialSearch {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                searchFocused = true
                            }
                        }
                    }

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
                Button(action: { search.sortOrder.toggle() }) {
                    Image(systemName:
                        "chevron.\(sortDirection).circle.fill"
                    )
                }

                .foregroundColor(.accentColor)

                Picker("Sort Value",  selection: $search.sortValue) {
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
        search.sortOrder == .ascending ? "up" : "down"
    }
}

struct PostSearch: View {
    @ObservedObject var search: PostQueryViewModel
    @ObservedObject var deleted: Deleted

    var body: some View {
        ScrollView {
            LazyVStack {
                SearchControls(search: search)

                if search.initialSearch {
                    ResultCount(type: "Post", count: search.total)
                }

                ForEach(search.hits) { post in
                    NavigationLink(destination: PostDetail(
                        id: post.id,
                        repo: search.repo,
                        deleted: $deleted.id
                    )) {
                        PostRow(post: post)
                    }
                }

                if search.resultsAvailable {
                    ProgressView()
                        .onAppear { search.nextPage() }
                        .progressViewStyle(.circular)
                }
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
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
                .environmentObject(DataSource.preview)
                .environmentObject(ObjectSource.preview)
        }
        .padding(.horizontal)
    }
}

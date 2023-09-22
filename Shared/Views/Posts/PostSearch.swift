import os
import Minty
import SwiftUI

private struct PostResults<Content>: View where Content : View {
    @EnvironmentObject private var data: DataSource

    let content: (PostViewModel) -> Content

    @Binding var query: String
    @Binding var tags: [TagViewModel]

    @State private var lastQuery = ""
    @State private var sort: PostQuery.Sort = .created
    @State private var posts: [PostViewModel] = []
    @State private var total = 0
    @State private var task: Task<Void, Never>?
    @State private var showProgress = false
    @State private var showTags = false
    @State private var error: String?

    var body: some View {
        PaddedScrollView {
            LazyVStack {
                if let error {
                    NoResults(
                        heading: "Failed to find posts",
                        subheading: error
                    )
                }
                else if task == nil && posts.isEmpty {
                    NoResults()
                }
                else {
                    InfiniteScroll(
                        posts,
                        stopIf: posts.count == total,
                        more: loadMore
                    ) { post in
                        content(post)
                        Divider()
                    }
                }
            }
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    TextField("Search", text: $query)
                        .submitLabel(.search)
                        .onSubmit(search)

                    Button(action: { query.removeAll() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .opacity(query.isEmpty ? 0 : 1)
                    }
                    .font(.caption)
                }
            }

            ToolbarItemGroup(placement: .primaryAction) {
                ProgressView()
                    .opacity(showProgress ? 1 : 0)

                Menu {
                    SortPicker(sort: $sort)

                    Button(action: { showTags = true }) {
                        Label("Tags", systemImage: "tag")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .tagListEditor(
            isPresented: $showTags,
            tags: tags,
            add: { tags.append($0) },
            remove: { tags.remove(element: $0) }
        )
        .onFirstAppearance(perform: search)
        .onDisappear { task?.cancel() }
        .onReceive(Post.deleted) { id in
            if posts.remove(id: id) != nil {
                total -= 1
            }
        }
        .onChange(of: query) {
            if query.isEmpty {
                search()
            }
        }
        .onChange(of: tags, search)
        .onChange(of: sort, search)
    }

    private func loadMore() async throws {
        let results = try await data.findPosts(
            text: query.trimmed,
            tags: tags,
            sort: sort,
            from: posts.count,
            size: 100
        )

        posts.append(contentsOf: results.hits)
        total = results.total
    }

    private func search() {
        task?.cancel()

        task = Task {
            let progress = Task.after(.milliseconds(100)) {
                withAnimation { showProgress = true }
            }

            defer { progress.cancel() }
            defer { task = nil }

            do {
                let results = try await data.findPosts(
                    text: query.trimmed,
                    tags: tags,
                    sort: sort,
                    size: 25
                )

                withAnimation {
                    showProgress = false
                    error = nil
                    posts = results.hits
                    total = results.total
                }
            }
            catch {
                if Task.isCancelled {
                    Logger.ui.debug("Post search cancelled")
                }
                else {
                    posts.removeAll()
                    total = 0
                    showProgress = false
                    self.error = error.localizedDescription
                }
            }
        }
    }
}

struct PostSearch<Content>: View where Content : View {
    @ViewBuilder let content: (PostViewModel) -> Content

    @State private var query = ""
    @State private var tags: [TagViewModel] = []
    @State private var resultsPresented = false

    @FocusState private var focused: Bool

    var body: some View {
        VStack {
            SearchField(text: $query)
                .onSubmit { resultsPresented = true }

            TagListEditorButton(tags: $tags) {
                Label("\(tags.count)", systemImage: "tag")
            } onDismiss: {
                if !tags.isEmpty {
                    resultsPresented = true
                }
            }
        }
        .navigationDestination(isPresented: $resultsPresented) {
            PostResults(content: content, query: $query, tags: $tags)
        }
    }
}

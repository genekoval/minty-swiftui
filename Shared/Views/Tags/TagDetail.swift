import os
import Minty
import SwiftUI

private struct TagInfo: View {
    @ObservedObject var tag: TagViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            aliases
            description
            sources
            created
            postCount
        }
        .padding()
    }

    @ViewBuilder
    private var aliases: some View {
        if !tag.aliases.isEmpty {
            VStack(alignment: .leading, spacing: 5) {
                ForEach(tag.aliases, id: \.self) { alias in
                    Text(alias)
                        .bold()
                        .font(.footnote)
                }
            }
            .padding(.leading, 10)
        }
    }

    @ViewBuilder
    private var created: some View {
        Timestamp(
            prefix: "Created",
            systemImage: "calendar",
            date: tag.dateCreated
        )
    }

    @ViewBuilder
    private var description: some View {
        if let description = tag.description {
            Text(description)
        }
    }

    @ViewBuilder
    private var sources: some View {
        if !tag.sources.isEmpty {
            ForEach(tag.sources) { SourceLink(source: $0) }
        }
    }

    @ViewBuilder
    private var postCount: some View {
        if tag.postCount > 0 {
            Label(
                tag.postCount.asCountOf("Post"),
                systemImage: "doc.text.image"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
}

private struct TagControls: View {
    @ObservedObject var tag: TagViewModel

    @Binding var sort: PostQuery.Sort

    var body: some View {
        HStack {
            Spacer()
            changeSort
            Spacer()
            share
            Spacer()
            newPost
            Spacer()
        }
        .padding(.top, 5)
    }

    @ViewBuilder
    private var changeSort: some View {
        SortPicker(sort: $sort)
            .labelStyle(.iconOnly)
    }

    @ViewBuilder
    private var newPost: some View {
        NewPostButton(tag: tag)
    }

    @ViewBuilder
    private var share: some View {
        ShareLink(item: tag.id.uuidString)
            .labelStyle(.iconOnly)
    }
}

private struct TagHeader: View {
    @Environment(\.isSearching) private var isSearching

    @ObservedObject var tag: TagViewModel

    @Binding var sort: PostQuery.Sort

    var body: some View {
        if !isSearching {
            TagInfo(tag: tag)
            TagControls(tag: tag, sort: $sort)
        }
    }
}

private struct TagPostSearch: View {
    @Environment(\.isSearching) private var isSearching

    @EnvironmentObject private var data: DataSource

    @Binding var posts: [PostViewModel]
    @Binding var total: Int

    let tag: TagViewModel
    let query: String
    let sort: PostQuery.Sort
    let error: String?

    var body: some View {
        LazyVStack {
            if let error {
                NoResults(heading: "Failed to load posts", subheading: error)
            }
            else if isSearching && posts.isEmpty {
                NoResults()
            }
            else {
                InfiniteScroll(
                    posts,
                    stopIf: posts.count == total,
                    more: loadMore
                ) {
                    PostLink(post: $0)
                    Divider()
                }
            }
        }
    }

    private func loadMore() async throws {
        let results = try await data.findPosts(
            text: query.trimmed,
            tags: [tag],
            sort: sort,
            from: posts.count,
            size: 100
        )

        posts.append(contentsOf: results.hits)
        total = results.total
    }
}

struct TagDetail: View {
    @EnvironmentObject private var data: DataSource
    @EnvironmentObject private var errorHandler: ErrorHandler

    @ObservedObject var tag: TagViewModel

    @State private var query = ""
    @State private var sort: PostQuery.Sort = .created

    @State private var posts: [PostViewModel] = []
    @State private var total = 0
    @State private var error: String?
    @State private var task: Task<Void, Never>?
    @State private var showProgress = false

    var body: some View {
        PaddedScrollView {
            TagHeader(tag: tag, sort: $sort)

            ProgressView()
                .opacity(showProgress ? 1 : 0)

            TagPostSearch(
                posts: $posts,
                total: $total,
                tag: tag,
                query: query,
                sort: sort,
                error: error
            )
        }
        .onDisappear { task?.cancel() }
        .onReceive(tag.$postCount) { postCount in
            if postCount > 0 {
                if task == nil && posts.isEmpty { search() }
            }
        }
        .onReceive(Post.deleted) { id in
            if posts.remove(id: id) != nil {
                total -= 1
            }
        }
        .refreshable {
            do {
                try await tag.refresh()
                if task == nil { search() }
            }
            catch {
                errorHandler.handle(error: error)
            }
        }
        .searchable(text: $query)
        .onSubmit(of: .search, search)
        .onChange(of: query) {
            if query.isEmpty {
                search()
            }
        }
        .onChange(of: sort, search)
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
                    tags: [tag],
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

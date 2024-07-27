import Minty
import SwiftUI
import os

private struct UserPostSearch: View {
    @Environment(\.isSearching) private var isSearching

    @EnvironmentObject private var data: DataSource

    @Binding var posts: [PostViewModel]
    @Binding var total: Int

    let user: User
    let query: String
    let sort: PostQuery.Sort
    let error: String?

    var body: some View {
        LazyVStack {
            if let error {
                NoResults(heading: "Failed to load posts", subheading: error)
            } else if isSearching && posts.isEmpty {
                NoResults()
            } else {
                InfiniteScroll(
                    posts,
                    stopIf: posts.count == total,
                    more: { [self] in try await self.loadMore() }
                ) {
                    PostLink(post: $0)
                    Divider()
                }
            }
        }
    }

    private func loadMore() async throws {
        let results = try await data.findPosts(
            poster: user,
            text: query.trimmed,
            sort: sort,
            from: posts.count,
            size: 100
        )

        posts.append(contentsOf: results.hits)
        total = results.total
    }
}

struct UserDetail: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var data: DataSource
    @EnvironmentObject private var errorHandler: ErrorHandler

    @ObservedObject var user: User

    @State private var query = ""
    @State private var sort: PostQuery.Sort = .created

    @State private var posts: [PostViewModel] = []
    @State private var total = 0
    @State private var error: String?
    @State private var task: Task<Void, Never>?
    @State private var showProgress = false

    var body: some View {
        PaddedScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if !user.aliases.isEmpty  {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(user.aliases, id: \.self) { alias in
                            Text(alias)
                                .bold()
                                .font(.footnote)
                        }
                    }
                    .padding(.bottom)
                }
                
                if !user.description.isEmpty {
                    Text(user.description)
                }

                if !user.sources.isEmpty {
                    ForEach(user.sources) { SourceLink(source: $0)}
                }

                emailLink

                if user.admin {
                    Label("Admin", systemImage: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundColor(.purple)
                }

                Timestamp(
                    prefix: "Joined",
                    systemImage: "calendar",
                    date: user.created
                )

                Group {
                    Label(
                        user.postCount.asCountOf("Post"),
                        systemImage: "doc.text.image"
                    )

                    Label(
                        user.commentCount.asCountOf("Comment"),
                        systemImage: "text.bubble"
                    )

                    Label(user.tagCount.asCountOf("Tag"), systemImage: "number")
                }
                .font(.caption)
                .foregroundColor(.secondary)

                HStack {
                    Spacer()
                    ShareLink(item: user.id.uuidString)
                    Spacer()
                }
                .labelStyle(.iconOnly)
            }
            .padding(.horizontal)

            ProgressView()
                .opacity(showProgress ? 1 : 0)

            UserPostSearch(
                posts: $posts,
                total: $total,
                user: user,
                query: query,
                sort: sort,
                error: error
            )

        }
        .navigationTitle(user.name)
        .navigationBarTitleDisplayMode(.large)
        .onDisappear { task?.cancel() }
        .onReceive(user.$postCount) { count in
            if count > 0 {
                if task == nil && posts.isEmpty { search() }
            }
        }
        .onReceive(User.deleted) { id in
            if id == user.id {
                dismiss()
            }
        }
        .onReceive(Post.deleted) { id in
            if posts.remove(id: id) != nil {
                total -= 1
            }
        }
        .refreshable {
            do {
                user.load(try await data.repo!.getUser(id: user.id))
                if task == nil { search() }
            } catch {
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

    private var email: URL? {
        URL(string: "mailto:\(user.email)")
    }

    @ViewBuilder
    private var emailLink: some View {
        if let email {
            Link(destination: email) {
                Label(user.email, systemImage: "envelope")
                    .font(.caption)
            }
        }
    }

    private func search() {
        task?.cancel()

        task = Task {
            let progress = Task.after(.milliseconds(100)) {
                withAnimation { showProgress = true }
            }

            defer {
                progress.cancel()
                task = nil
            }

            do {
                let results = try await data.findPosts(
                    poster: user,
                    text: query.trimmed,
                    sort: sort,
                    size: 25
                )

                withAnimation { showProgress = false }

                error = nil
                posts = results.hits
                total = results.total
            } catch {
                if Task.isCancelled {
                    Logger.ui.debug("User post search cancelled")
                } else {
                    posts.removeAll()
                    total = 0
                    showProgress = false
                    self.error = error.localizedDescription
                }
            }
        }
    }
}

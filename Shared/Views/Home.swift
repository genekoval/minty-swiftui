import Minty
import Shimmer
import SwiftUI

private enum SearchState: Equatable {
    case searching
    case done
    case error(String)
}

struct Home: View {
    @EnvironmentObject private var data: DataSource

    @State private var posts: [PostViewModel] = []
    @State private var total = 0
    @State private var state: SearchState = .searching

    var body: some View {
        NavigationStack {
            PaddedScrollView {
                LazyVStack {
                    switch state {
                    case .searching:
                        loading
                    case .done:
                        InfiniteScroll(
                            posts,
                            stopIf: posts.count == total,
                            more: { [self] in try await self.loadMore() }
                        ) {
                            PostLink(post: $0)
                            Divider()
                        }
                    case .error(let message):
                        NoResults(
                            heading: "Couldn't Load Posts",
                            subheading: message
                        )
                        .padding()
                    }
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable { [self] in await self.search() }
            .scrollDisabled(state == .searching)
            .onReceive(data.$repo) { repo in
                guard repo != nil else { return }

                Task {
                    await search()
                }
            }
            .onReceive(Post.deleted) { id in
                if posts.remove(id: id) != nil {
                    total -= 1
                }
            }
        }
    }

    @ViewBuilder
    private var loading: some View {
        ForEach(1...50, id: \.self) { _ in
            PostRow(post: .placeholder)
            Divider()
        }
        .redacted(reason: .placeholder)
        .shimmering()
    }

    private func loadMore() async throws {
        let results = try await data.findPosts(from: posts.count, size: 100)

        posts.append(contentsOf: results.hits)
        total = results.total
    }

    private func search() async {
        do {
            let results = try await data.findPosts(size: 25)

            withAnimation {
                state = .done
                posts = results.hits
                total = results.total
            }
        }
        catch {
            if !Task.isCancelled {
                state = .error(error.localizedDescription)
            }
        }
    }
}

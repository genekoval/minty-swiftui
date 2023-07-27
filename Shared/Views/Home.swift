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
    @State private var trailingError: String?

    var body: some View {
        NavigationStack {
            PaddedScrollView {
                switch state {
                case .searching:
                    loading
                case .done:
                    results
                case .error(let message):
                    NoResults(
                        heading: "Couldn't Load Posts",
                        subheading: message
                    )
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable(action: search)
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
        ForEach(0..<50, id: \.self) { _ in
            PostRow(post: .placeholder)
                .redacted(reason: .placeholder)
                .shimmering()
        }
    }

    @ViewBuilder
    private var results: some View {
        LazyVStack {
            ForEach(posts) { post in
                NavigationLink(destination: PostHost(post: post)) {
                    PostRow(post: post)
                }
                .buttonStyle(.plain)

                Divider()
            }

            if let trailingError {
                Text("Could't Load Posts")
                    .bold()
                    .font(.headline)

                Text(trailingError)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            else if posts.count < total {
                ProgressView()
                    .padding()
                    .task(loadMore)
            }
        }
    }

    @Sendable
    private func loadMore() async {
        do {
            let results = try await data.findPosts(from: posts.count, size: 100)

            posts.append(contentsOf: results.hits)
            total = results.total
        }
        catch {
            if !Task.isCancelled {
                trailingError = error.localizedDescription
            }
        }
    }

    @Sendable
    private func search() async {
        do {
            let results = try await data.findPosts(size: 25)

            withAnimation {
                state = .done
                posts = results.hits
                total = results.total
                trailingError = nil
            }
        }
        catch {
            if !Task.isCancelled {
                state = .error(error.localizedDescription)
            }
        }
    }
}

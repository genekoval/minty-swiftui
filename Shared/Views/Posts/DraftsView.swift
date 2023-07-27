import SwiftUI

struct DraftsLink: View {
    @EnvironmentObject private var data: DataSource
    @EnvironmentObject private var user: CurrentUser

    @State private var task: Task<Void, Never>?
    @State private var error: String?

    var body: some View {
        NavigationLink(destination: DraftsView(task: $task, error: $error)) {
            Label("Drafts", systemImage: "doc")
                .badge(user.totalDrafts)
        }
        .onFirstAppearance(perform: fetch)
    }

    private func fetch() {
        task = Task {
            defer { task = nil }

            do {
                let results = try await data.findPosts(
                    visibility: .draft,
                    size: 25
                )

                withAnimation {
                    task = nil
                    user.drafts = results.hits
                    user.totalDrafts = results.total
                }
            }
            catch {
                self.error = error.localizedDescription
            }
        }
    }
}

struct DraftsView: View {
    @EnvironmentObject private var data: DataSource
    @EnvironmentObject private var user: CurrentUser

    @Binding var task: Task<Void, Never>?
    @Binding var error: String?

    var body: some View {
        PaddedScrollView {
            LazyVStack {
                if let task {
                    ProgressView { Text("Loading") }
                        .padding()
                        .task { await task.value }
                }
                else if let error {
                    NoResults(
                        heading: "Couldn't Load Drafts",
                        subheading: error
                    )
                    .padding()
                }
                else if user.drafts.isEmpty {
                    NoResults(
                        heading: "No Drafts",
                        subheading: "Post drafts you create can be found here."
                    )
                    .padding()
                }
                else {
                    InfiniteScroll(
                        user.drafts,
                        stopIf: user.drafts.count == user.totalDrafts,
                        more: loadMore
                    ) {
                        PostLink(post: $0)
                        Divider()
                    }
                }
            }
        }
        .navigationTitle(user.totalDrafts.asCountOf("Draft"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { NewPostButton() }
        .refreshable(action: refresh)
    }

    private func loadMore() async throws {
        let results = try await data.findPosts(
            visibility: .draft,
            from: user.drafts.count,
            size: 100
        )

        user.drafts.append(contentsOf: results.hits)
        user.totalDrafts = results.total
    }

    @Sendable
    private func refresh() async {
        guard task == nil else { return }

        do {
            let results = try await data.findPosts(visibility: .draft, size: 25)

            error = nil

            withAnimation {
                user.drafts = results.hits
                user.totalDrafts = results.total
            }
        }
        catch {
            if !Task.isCancelled {
                self.error = error.localizedDescription
            }
        }
    }
}

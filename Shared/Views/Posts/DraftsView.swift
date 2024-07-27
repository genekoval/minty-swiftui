import SwiftUI

struct DraftsLink: View {
    @EnvironmentObject private var data: DataSource

    @ObservedObject var user: User

    @State private var task: Task<Void, Never>?
    @State private var error: String?

    var body: some View {
        NavigationLink(
            destination: DraftsView(user: user, task: $task, error: $error)
        ) {
            Label("Drafts", systemImage: "doc")
                .badge(user.totalDrafts)
        }
        .onReceive(user.$draftsChecked) { draftsChecked in
            if !draftsChecked {
                fetch()
                user.draftsChecked = true
            }
        }
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

    @ObservedObject var user: User

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
                        more: { [self] in try await self.loadMore() }
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
        .refreshable { [self] in await self.refresh() }
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

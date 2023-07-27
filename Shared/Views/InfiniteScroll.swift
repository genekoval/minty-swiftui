import SwiftUI

struct InfiniteScroll<Data, Content>: View where
    Data : RandomAccessCollection,
    Data.Element : Identifiable,
    Content : View
{
    private let data: Data
    private let stop: Bool
    private let more: () async throws -> Void
    private let content: (Data.Element) -> Content

    @State private var error: String?

    var body: some View {
        ForEach(data, content: content)

        if let error {
            VStack(spacing: 10) {
                Text("Failed to load additional items.")
                    .bold()
                    .font(.headline)

                Text(error)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Button(action: retry) {
                    Label("Retry", systemImage: "arrow.clockwise")
                }
            }
            .multilineTextAlignment(.center)
            .padding()
        }
        else if !stop {
            ProgressView()
                .padding()
                .task(fetch)
        }
    }

    init(
        _ data: Data,
        stopIf stop: Bool = false,
        more: @escaping () async throws -> Void,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.stop = stop
        self.more = more
        self.content = content
    }

    @Sendable
    private func fetch() async {
        do {
            try await more()
        }
        catch let error as DisplayError {
            self.error = error.message
        }
        catch {
            if !Task.isCancelled {
                self.error = "Please try again later."
            }
        }
    }

    private func retry() {
        error = nil
    }
}

struct InfiniteScroll_Previews: PreviewProvider {
    private struct Preview: View {
        @State private var posts: [PostViewModel] = []
        @State private var total = 0
        @State private var fetches = 0
        @State private var fail = false
        @State private var delay = false

        var body: some View {
            NavigationStack {
                ScrollView {
                    LazyVStack {
                        InfiniteScroll(
                            posts,
                            stopIf: posts.count == total,
                            more: loadMore
                        ) {
                            PostRow(post: $0)
                        }
                    }
                }
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Toggle("Fail", isOn: $fail)
                    }

                    ToolbarItem(placement: .cancellationAction) {
                        Toggle("Delay", isOn: $delay)
                    }
                }
                .onFirstAppearance {
                    posts.append(
                        contentsOf: [PostViewModel].generate(count: 20)
                    )

                    total = 200
                }
            }
        }

        private var title: String {
            "\(posts.count) of \(total) Posts (\(fetches))"
        }

        private func loadMore() async throws {
            defer { fetches += 1 }

            if delay {
                try await Task.sleep(for: .seconds(3))
            }

            if fail {
                throw DisplayError("Please try again.")
            }

            await posts.append(contentsOf: [PostViewModel].generate(count: 10))
        }
    }

    static var previews: some View {
        Preview()
    }
}

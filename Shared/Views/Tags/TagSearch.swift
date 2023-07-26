import Minty
import SwiftUI

private enum SearchState {
    case none
    case done
    case searching
    case error(String)
}

private struct TagSearchOverlay<Content>: View where Content : View {
    @Environment(\.isSearching) private var isSearching

    @EnvironmentObject private var data: DataSource
    @EnvironmentObject private var errorHandler: ErrorHandler

    @Binding var tags: [TagViewModel]
    @Binding var total: Int

    let name: String
    let exclude: [TagViewModel]
    let state: SearchState
    let content: (TagViewModel) -> Content

    var body: some View {
        if isSearching {
            ZStack {
                Rectangle()
                    .fill(.background)

                PaddedScrollView {
                    switch state {
                    case .none:
                        // Maybe show search history here
                        EmptyView()
                    case .done:
                        results
                    case .searching:
                        ProgressView { Text("Searching") }
                            .padding()
                    case .error(let message):
                        NoResults(heading: "Search Failed", subheading: message)
                    }
                }
            }
        }
    }

    private var complete: Bool {
        tags.count == total
    }

    private var noResultsText: String {
        "There were no results for “\(name)”. Try a new search."
    }

    @ViewBuilder
    private var results: some View {
        if tags.isEmpty {
            NoResults(subheading: noResultsText)
        }
        else {
            LazyVStack {
                ForEach(tags) {
                    content($0)
                    Divider()
                }

                if !complete {
                    ProgressView()
                        .padding()
                        .task(loadMore)
                }
            }
            .padding()
        }
    }

    @Sendable
    private func loadMore() async {
        do {
            let result = try await data.findTags(
                name.trimmingCharacters(in: .whitespaces),
                exclude: exclude,
                from: tags.count,
                size: 100
            )

            tags.append(contentsOf: result.hits)
            total = result.total
        }
        catch {
            errorHandler.handle(error: error)
        }
    }
}

private struct TagSearch<TagView>: ViewModifier where TagView : View {
    @EnvironmentObject private var data: DataSource

    let exclude: [TagViewModel]
    let tagView: (TagViewModel) -> TagView

    @State private var name = ""
    @State private var state: SearchState = .none
    @State private var tags: [TagViewModel] = []
    @State private var total = 0
    @State private var task: Task<Void, Never>?

    func body(content: Content) -> some View {
        ZStack {
            content
            TagSearchOverlay(
                tags: $tags,
                total: $total,
                name: name,
                exclude: exclude,
                state: state,
                content: tagView
            )
        }
        .searchable(text: $name)
        .onChange(of: name, perform: search)
        .onReceive(Tag.deleted, perform: removeTag)
        .onSubmit(of: .search, search)
    }

    @discardableResult
    private func after(
        _ delay: ContinuousClock.Instant.Duration,
        perform: @escaping () -> Void
    ) -> Task<Void, Never> {
        Task {
            do {
                try await Task.sleep(for: delay)
            }
            catch {
                return
            }

            perform()
        }
    }

    private func removeTag(id: Tag.ID) {
        if tags.remove(id: id) != nil {
            total -= 1
        }
    }

    private func reset() {
        if !tags.isEmpty {
            tags.removeAll()
            total = 0
        }

        state = .none
    }

    private func search() {
        search(for: name)
    }

    private func search(for name: String) {
        task?.cancel()

        guard let name = name.trimmed else {
            reset()
            return
        }

        task = Task {
            let progress = after(.milliseconds(50)) { state = .searching }
            defer { progress.cancel() }

            do {
                let result = try await data.findTags(
                    name,
                    exclude: exclude,
                    size: 50
                )

                tags = result.hits
                total = result.total
                state = .done
            }
            catch {
                if !Task.isCancelled {
                    state = .error(error.localizedDescription)
                }
            }
        }
    }
}

extension View {
    func tagSearch(exclude: [TagViewModel] = []) -> some View {
        tagSearch(exclude: exclude) {
            TagRow(tag: $0)
        }
    }

    func tagSearch<Content: View>(
        exclude: [TagViewModel] = [],
        _ content: @escaping (TagViewModel) -> Content
    ) -> some View {
        modifier(TagSearch(exclude: exclude, tagView: content))
    }
}

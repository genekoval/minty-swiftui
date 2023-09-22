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
                    LazyVStack {
                        switch state {
                        case .none:
                            // Maybe show search history here
                            EmptyView()
                        case .done:
                            results
                        case .searching:
                            ProgressView { Text("Searching") }
                        case .error(let message):
                            NoResults(
                                heading: "Search Failed",
                                subheading: message
                            )
                        }
                    }
                    .padding()
                }
            }
        }
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
            InfiniteScroll(
                tags,
                stopIf: tags.count == total,
                more: loadMore
            ) {
                content($0)
                Divider()
            }
        }
    }

    private func loadMore() async throws {
        let result = try await data.findTags(
            name.trimmingCharacters(in: .whitespaces),
            exclude: exclude,
            from: tags.count,
            size: 100
        )

        tags.append(contentsOf: result.hits)
        total = result.total
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
        .onChange(of: name, search)
        .onReceive(Tag.deleted, perform: removeTag)
        .onSubmit(of: .search, search)
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
        task?.cancel()

        guard let name = name.trimmed else {
            reset()
            return
        }

        task = Task {
            let progress = Task.after(.milliseconds(50)) { state = .searching }
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

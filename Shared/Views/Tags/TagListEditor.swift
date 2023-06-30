import SwiftUI

private struct TagSelectRow: View {
    @EnvironmentObject private var errorHandler: ErrorHandler

    let tag: TagViewModel
    let post: PostViewModel

    var body: some View {
        SelectableRow(
            onSelected: onSelected,
            onDeselected: onDeselected
        ) {
            TagLink(tag: tag)
        }
        .padding(.horizontal)
    }

    private func onDeselected() {
        errorHandler.handle {
            try await post.delete(tag: tag)
        }
    }

    private func onSelected() {
        errorHandler.handle {
            try await post.add(tag: tag)
        }
    }
}

private struct EditorRow: View {
    @EnvironmentObject private var errorHandler: ErrorHandler

    let tag: TagViewModel
    let post: PostViewModel

    var body: some View {
        Row {
            HStack {
                Button(action: deleteTag) {
                    Checkmark(isChecked: true)
                }

                TagLink(tag: tag)
            }
        }
        .padding(.horizontal)
    }

    private func deleteTag() {
        errorHandler.handle {
            try await post.delete(tag: tag)
        }
    }
}

struct TagListEditor: View {
    @Environment(\.isSearching) private var isSearching

    @ObservedObject var post: PostViewModel
    @ObservedObject var search: TagQueryViewModel

    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    ForEach(post.tags) {
                        EditorRow(tag: $0, post: post)
                    }
                }
                .padding(.vertical)
            }

            searchOverlay
        }
    }

    @ViewBuilder
    private var searchOverlay: some View {
        if isSearching {
            ScrollView {
                LazyVStack {
                    TagSearchBase(search: search) {
                        TagSelectRow(tag: $0, post: post)
                    }
                }
            }
            .background {
                Rectangle()
                    .fill(.background)
            }
        }
    }
}

struct TagListEditorButton: View {
    @ObservedObject var post: PostViewModel

    @State private var isPresented = false

    @StateObject private var search = TagQueryViewModel()

    var body: some View {
        Button(action: { isPresented = true }) {
            Label("Tags", systemImage: "tag")
        }
        .prepareSearch(search)
        .badge(post.tags.count)
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                TagListEditor(post: post, search: search)
                    .searchable(text: $search.name, prompt: "Find tags")
                    .navigationTitle(title)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            DismissButton()
                        }
                    }
                    .onReceive(post.$tags) { search.excluded = $0 }
            }
        }
    }

    private var title: String {
        let count = post.tags.count
        return "\(count) Tag\(count == 1 ? "" : "s")"
    }
}

import Minty
import SwiftUI

private struct TagSelectRow: View {
    let tag: TagViewModel
    let onSelect: () -> Void
    let onDeselect: () -> Void

    @State private var isSelected = false

    var body: some View {
        VStack {
            HStack {
                SelectButton(isSelected: $isSelected.onChange(selectionChanged))
                    .frame(width: 30, height: 30)
                TagRow(tag: tag)
            }

            Divider()
        }
        .padding(.horizontal)
    }

    private func selectionChanged(to selection: Bool) {
        selection ? onSelect() : onDeselect()
    }
}

private struct SearchView<Content: View>: View {
    @ObservedObject var search: TagQueryViewModel
    @ViewBuilder let content: (TagViewModel) -> Content

    var body: some View {
        ScrollView {
            LazyVStack {
                if !search.name.isEmpty {
                    ResultCount(
                        type: "Tag",
                        count: search.total,
                        text: search.name
                    )
                }

                ForEach(search.hits) { tag in
                    content(tag)
                }

                if search.resultsAvailable {
                    ProgressView()
                        .onAppear { search.nextPage() }
                        .progressViewStyle(.circular)
                }
            }
        }
    }
}

private struct TagSelectorCore: View {
    @Environment(\.isSearching) var isSearching

    @Binding var tags: [TagViewModel]
    @ObservedObject var search: TagQueryViewModel

    var onAdd: ((TagViewModel) -> Void)?
    var onRemove: ((TagViewModel) -> Void)?

    var body: some View {
        if isSearching {
            SearchView(search: search) { tag in
                TagSelectRow(tag: tag, onSelect: {
                    add(tag: tag)
                }, onDeselect: {
                    if let index = tags.firstIndex(where: { tag.id == $0.id }) {
                        remove(index: index)
                    }
                })
            }
        }
        else {
            Form {
                Section {
                    HStack {
                        Image(systemName: "tag")
                        Text("Tags")

                        Spacer()

                        Text("\(tags.count)")
                            .foregroundColor(.secondary)
                    }

                    if !tags.isEmpty {
                        Button("Remove All") { tags.removeAll() }
                    }
                }

                Section {
                    ForEach(tags) { tag in
                        TagRow(tag: tag)
                    }
                    .onDelete { offsets in
                        if let index = offsets.first {
                            remove(index: index)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private func add(tag: TagViewModel) {
        onAdd?(tag)
        tags.append(tag)
    }

    private func remove(index: Int) {
        onRemove?(tags[index])
        tags.remove(at: index)
    }
}

struct TagSelector: View {
    @Environment(\.dismiss) var dimiss

    @Binding var tags: [TagViewModel]
    @ObservedObject var search: TagQueryViewModel

    private let onAdd: ((TagViewModel) -> Void)?
    private let onRemove: ((TagViewModel) -> Void)?

    var body: some View {
        TagSelectorCore(
            tags: $tags.onChange(tagsChanged),
            search: search,
            onAdd: onAdd,
            onRemove: onRemove
        )
        .searchable(text: $search.name)
        .navigationTitle("Selected Tags")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button(action: { dimiss() }) {
                Text("Done")
                    .bold()
            }
        }
    }

    init(
        tags: Binding<[TagViewModel]>,
        search: TagQueryViewModel,
        onAdd: ((TagViewModel) -> Void)? = nil,
        onRemove: ((TagViewModel) -> Void)? = nil
    ) {
        _tags = tags
        self.search = search
        self.onAdd = onAdd
        self.onRemove = onRemove
    }

    private func tagsChanged(to value: [TagViewModel]) {
        search.excluded = value
    }
}

struct TagSelector_Previews: PreviewProvider {
    private struct Preview: View {
        @StateObject private var search = TagQueryViewModel.preview()
        @State private var tags: [TagViewModel] = []

        var body: some View {
            NavigationView {
                TagSelector(tags: $tags, search: search)
            }
        }
    }

    static var previews: some View {
        Preview()
    }
}

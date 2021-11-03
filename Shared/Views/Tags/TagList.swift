import Minty
import SwiftUI

private struct TagSelectRow: View {
    let tag: TagPreview
    let onSelect: () -> Void
    let onDeselect: () -> Void

    @State private var isSelected = false

    var body: some View {
        VStack {
            HStack {
                SelectButton(isSelected: $isSelected.onChange(selectionChanged))
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
    @ViewBuilder let content: (TagPreview) -> Content

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

private struct TagListCore: View {
    @Environment(\.isSearching) var isSearching

    @Binding var tags: [TagPreview]
    @ObservedObject var search: TagQueryViewModel

    var body: some View {
        if isSearching {
            SearchView(search: search) { tag in
                TagSelectRow(tag: tag, onSelect: {
                    tags.append(tag)
                }, onDeselect: {
                    if let index = tags.firstIndex(of: tag) {
                        tags.remove(at: index)
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
                            tags.remove(at: index)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct TagList: View {
    @Environment(\.dismiss) var dimiss

    @Binding var tags: [TagPreview]
    @ObservedObject var search: TagQueryViewModel

    var body: some View {
        NavigationView {
            TagListCore(tags: $tags.onChange(tagsChanged), search: search)
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
    }

    private func tagsChanged(to value: [TagPreview]) {
        search.excluded = value
    }
}

struct TagList_Previews: PreviewProvider {
    @StateObject private static var search = TagQueryViewModel.preview()

    static var previews: some View {
        TagList(tags: .constant([TagPreview]()), search: search)
    }
}

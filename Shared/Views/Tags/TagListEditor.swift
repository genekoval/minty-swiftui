import SwiftUI

private struct TagSelectRow: View {
    private let tag: TagViewModel

    private let add: (TagViewModel) -> Void
    private let remove: (TagViewModel) -> Void

    @State private var isSelected: Bool

    var body: some View {
        SelectableRow(isSelected: $isSelected) {
            TagRow(tag: tag)
        }
        .onChange(of: isSelected, perform: selectionChanged)
    }

    init(
        tag: TagViewModel,
        add: @escaping (TagViewModel) -> Void,
        remove: @escaping (TagViewModel) -> Void,
        isSelected: Bool = false
    ) {
        self.tag = tag
        self.add = add
        self.remove = remove
        self.isSelected = isSelected
    }

    private func selectionChanged(to selected: Bool) {
        if selected {
            add(tag)
        }
        else {
            remove(tag)
        }
    }
}

private struct TagListEditor: View {
    let tags: [TagViewModel]
    let add: (TagViewModel) -> Void
    let remove: (TagViewModel) -> Void

    var body: some View {
        ScrollView {
            VStack {
                ForEach(tags) {
                    TagSelectRow(
                        tag: $0,
                        add: add,
                        remove: remove,
                        isSelected: true
                    )
                    Divider()
                }
            }
            .padding()
        }
        .toolbar {
            NewTagButton(onCreated: add)
        }
        .tagSearch(exclude: tags) {
            TagSelectRow(
                tag: $0,
                add: add,
                remove: remove
            )
        }
    }
}

private struct TagListEditorSheet: ViewModifier {
    @Binding var isPresented: Bool

    let tags: [TagViewModel]
    let add: (TagViewModel) -> Void
    let remove: (TagViewModel) -> Void
    let onDismiss: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented, onDismiss: onDismiss) {
                NavigationStack {
                    TagListEditor(
                        tags: tags,
                        add: add,
                        remove: remove
                    )
                    .navigationTitle(tags.countOf(type: "Tag"))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            DismissButton()
                        }
                    }
                }
            }
    }
}

extension View {
    func tagListEditor(
        isPresented: Binding<Bool>,
        tags: [TagViewModel],
        add: @escaping (TagViewModel) -> Void,
        remove: @escaping (TagViewModel) -> Void,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        modifier(TagListEditorSheet(
            isPresented: isPresented,
            tags: tags,
            add: add,
            remove: remove,
            onDismiss: onDismiss
        ))
    }
}

struct TagListEditorButton<Content>: View where Content : View {
    private let content: () -> Content
    private let onDismiss: (() -> Void)?

    @Binding private var tags: [TagViewModel]

    @State private var isPresented = false

    var body: some View {
        Button(action: { isPresented = true }) { content() }
            .tagListEditor(
                isPresented: $isPresented,
                tags: tags,
                add: { tags.append($0) },
                remove: { tags.remove(element: $0) },
                onDismiss: onDismiss
            )
    }

    init(
        tags: Binding<[TagViewModel]>,
        @ViewBuilder content: @escaping () -> Content,
        onDismiss: (() -> Void)? = nil
    ) {
        self.content = content
        self.onDismiss = onDismiss
        _tags = tags
    }
}

struct PostTagEditorButton: View {
    @EnvironmentObject private var errorHandler: ErrorHandler

    @ObservedObject var post: PostViewModel

    @State private var isPresented = false

    var body: some View {
        Button(action: { isPresented = true }) {
            Label("Tags", systemImage: "tag")
        }
        .badge(post.tags.count)
        .tagListEditor(
            isPresented: $isPresented,
            tags: post.tags,
            add: add,
            remove: remove
        )
    }

    private func add(tag: TagViewModel) {
        errorHandler.handle {
            try await post.add(tag: tag)
        }
    }

    private func remove(tag: TagViewModel) {
        errorHandler.handle {
            try await post.delete(tag: tag)
        }
    }
}

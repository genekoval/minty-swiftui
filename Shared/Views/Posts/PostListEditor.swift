import SwiftUI

private struct PostSelectRow: View {
    private let post: PostViewModel

    private let add: (PostViewModel) -> Void
    private let remove: (PostViewModel) -> Void

    @State private var isSelected: Bool

    var body: some View {
        SelectableRow(isSelected: $isSelected) {
            NavigationLink(destination: PostHost(post: post)) {
                PostRowMinimal(post: post)
            }
            .buttonStyle(.plain)
        }
        .onChange(of: isSelected) {
            if isSelected {
                add(post)
            }
            else {
                remove(post)
            }
        }
    }

    init(
        post: PostViewModel,
        add: @escaping (PostViewModel) -> Void,
        remove: @escaping (PostViewModel) -> Void,
        isSelected: Bool = false
    ) {
        self.post = post
        self.add = add
        self.remove = remove
        self.isSelected = isSelected
    }
}

private struct PostListEditor: View {
    let posts: [PostViewModel]
    let add: (PostViewModel) -> Void
    let remove: (PostViewModel) -> Void

    var body: some View {
        ScrollView {
            VStack {
                PostSearch { post in
                    PostSelectRow(post: post, add: add, remove: remove)
                        .padding(.horizontal)
                }

                ForEach(posts) {
                    PostSelectRow(
                        post: $0,
                        add: add,
                        remove: remove,
                        isSelected: true
                    )
                    Divider()
                }
            }
            .padding()
        }
    }
}

private struct PostListEditorSheet: ViewModifier {
    @Binding var isPresented: Bool

    let posts: [PostViewModel]
    let add: (PostViewModel) -> Void
    let remove: (PostViewModel) -> Void
    let onDismiss: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented, onDismiss: onDismiss) {
                NavigationStack {
                    PostListEditor(
                        posts: posts,
                        add: add,
                        remove: remove
                    )
                    .navigationTitle(posts.countOf(type: "Post"))
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
    func postListEditor(
        isPresented: Binding<Bool>,
        posts: [PostViewModel],
        add: @escaping (PostViewModel) -> Void,
        remove: @escaping(PostViewModel) -> Void,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        modifier(PostListEditorSheet(
            isPresented: isPresented,
            posts: posts,
            add: add,
            remove: remove,
            onDismiss: onDismiss
        ))
    }
}

struct RelatedPostsEditorButton: View {
    @EnvironmentObject private var errorHandler: ErrorHandler

    @ObservedObject var post: PostViewModel

    @State private var isPresented = false

    var body: some View {
        SecondaryButton(action: { isPresented = true }) {
            Label(label, systemImage: "doc.text.image")
        }
        .postListEditor(
            isPresented: $isPresented,
            posts: post.posts,
            add: add,
            remove: remove
        )
    }

    private var label: String {
        if post.posts.isEmpty {
            return "Link Posts"
        }

        return post.posts.count.asCountOf("Related Post")
    }

    private func add(related: PostViewModel) {
        errorHandler.handle {
            try await post.add(post: related)
        }
    }

    private func remove(related: PostViewModel) {
        errorHandler.handle {
            try await post.delete(post: related)
        }
    }
}

import SwiftUI

struct PostEditor: View {
    @Environment(\.dismiss) var dismiss

    @ObservedObject var post: PostViewModel

    @StateObject private var tagSearch: TagQueryViewModel

    var body: some View {
        NavigationView {
            Form {
                EditorLink(
                    title: "Title",
                    onSave: { post.commitTitle() },
                    draft: $post.draftTitle,
                    original: post.title
                )

                EditorLink(
                    title: "Description",
                    onSave: { post.commitDescription() },
                    draft: $post.draftDescription,
                    original: post.description
                )

                Section {
                    NavigationLink(destination: ObjectEditorGrid(post: post)) {
                        HStack {
                            Label("Objects", systemImage: "doc")
                            Spacer()
                            Text("\(post.objects.count)")
                                .foregroundColor(.secondary)
                        }
                    }

                    NavigationLink(destination: TagSelector(
                        tags: $post.tags,
                        search: tagSearch,
                        onAdd: { post.addTag(tag: $0) },
                        onRemove: { post.removeTag(tag: $0) }
                    )) {
                        HStack {
                            Label("Tags", systemImage: "tag")
                            Spacer()
                            Text("\(post.tags.count)")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                DeleteButton(for: "Post") { delete() }
            }
            .navigationTitle("Edit Post")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { tagSearch.excluded = post.tags }
            .toolbar {
                Button(action: { dismiss() }) {
                    Text("Done")
                        .bold()
                }
            }
        }
    }

    init(post: PostViewModel) {
        self.post = post
        _tagSearch = StateObject(
            wrappedValue: TagQueryViewModel(repo: post.repo)
        )
    }

    private func delete() {
        post.delete()
        dismiss()
    }
}

struct PostEditor_Previews: PreviewProvider {
    private static let deleted = Deleted()
    private static let post = PostViewModel.preview(
        id: "test",
        deleted: deleted
    )

    static var previews: some View {
        PostEditor(post: post)
            .environmentObject(ObjectSource.preview)
    }
}

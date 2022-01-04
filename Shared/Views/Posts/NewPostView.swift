import Combine
import Minty
import SwiftUI

struct NewPostView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject private var post: NewPostViewModel
    @StateObject private var tagSearch: TagQueryViewModel

    var body: some View {
        NavigationView {
            Form {
                titleEditor
                descriptionEditor

                Section {
                    objectEditor
                    tagSelector
                }
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) { doneButton }
                ToolbarItem(placement: .cancellationAction) { cancelButton }
            }
        }
    }

    @ViewBuilder
    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
    }

    @ViewBuilder
    private var descriptionEditor: some View {
        EditorLink(
            title: "Description",
            onSave: { post.commitDescription() },
            draft: $post.draftDescription,
            original: post.description
        )
    }

    @ViewBuilder
    private var doneButton: some View {
        Button(action: { create() }) {
            Text("Done")
                .bold()
        }
        .disabled(!post.isValid)
    }

    @ViewBuilder
    private var objectEditor: some View {
        NavigationLink(destination: ObjectEditorGrid(collection: post)) {
            HStack {
                Label("Objects", systemImage: "doc")
                Spacer()
                Text("\(post.objects.count)")
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    private var tagSelector: some View {
        NavigationLink(destination: TagSelector(
            tags: $post.tags,
            search: tagSearch,
            onAdd: { _ in },
            onRemove: { _ in }
        )) {
            HStack {
                Label("Tags", systemImage: "tag")
                Spacer()
                Text("\(post.tags.count)")
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    private var titleEditor: some View {
        EditorLink(
            title: "Title",
            onSave: { post.commitTitle() },
            draft: $post.draftTitle,
            original: post.title
        )
    }

    init(repo: MintyRepo?, tag: TagPreview? = nil) {
        _post = StateObject(
            wrappedValue: NewPostViewModel(repo: repo, tag: tag)
        )
        _tagSearch = StateObject(wrappedValue: TagQueryViewModel(repo: repo))
    }

    private func create() {
        post.create()
        dismiss()
    }
}

struct NewPostView_Previews: PreviewProvider {
    static var previews: some View {
        NewPostView(repo: PreviewRepo())
            .environmentObject(ObjectSource.preview)
    }
}

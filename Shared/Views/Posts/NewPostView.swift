import Combine
import Minty
import SwiftUI

struct NewPostView: View {
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var errorHandler: ErrorHandler

    @StateObject private var post: NewPostViewModel
    @StateObject private var tagSearch = TagQueryViewModel()

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
            .loadEntity(post)
            .prepareSearch(tagSearch)
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
            text: $post.description
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
            text: $post.title
        )
    }

    init(tag: TagPreview? = nil) {
        _post = StateObject(wrappedValue: NewPostViewModel(tag: tag))
    }

    private func create() {
        do {
            try post.create()
            dismiss()
        }
        catch {
            errorHandler.handle(error: error)
        }
    }
}

struct NewPostView_Previews: PreviewProvider {
    static var previews: some View {
        NewPostView()
            .withErrorHandling()
            .environmentObject(ObjectSource.preview)
    }
}

import Combine
import Minty
import SwiftUI

struct NewPostView: View {
    let onCreated: (UUID) -> Void

    @StateObject private var post: NewPostViewModel
    @StateObject private var tagSearch = TagQueryViewModel()

    var body: some View {
        SheetView(title: "New Post", done: (
            label: "Done",
            action: create,
            disabled: { !post.isValid }
        )) {
            Form {
                titleEditor
                descriptionEditor

                Section {
                    objectEditor
                    tagSelector
                }
            }
            .loadEntity(post)
            .prepareSearch(tagSearch)
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

    init(onCreated: @escaping (UUID) -> Void, tag: TagViewModel? = nil) {
        self.onCreated = onCreated
        _post = StateObject(wrappedValue: NewPostViewModel(tag: tag))
    }

    private func create() async throws {
        let id = try await post.create()
        onCreated(id)
    }
}

struct NewPostView_Previews: PreviewProvider {
    static var previews: some View {
        NewPostView(onCreated: { _ in })
            .withErrorHandling()
            .environmentObject(DataSource.preview)
            .environmentObject(ObjectSource.preview)
    }
}

import Minty
import SwiftUI

private struct PostSelectRow: View {
    @EnvironmentObject var errorHandler: ErrorHandler

    let post: PostPreview

    @ObservedObject var parent: PostViewModel

    var body: some View {
        VStack {
            HStack {
                Button(action: selectionChanged) {
                    SelectionIndicator(isSelected: selected)
                }

                PostRowContainer(post: post)
            }
            Divider()
        }
        .padding(.horizontal)
    }

    private var selected: Bool {
        parent.posts.contains(post)
    }

    private func addPost() {
        errorHandler.handle { try parent.add(post: post) }
    }

    private func removePost() {
        errorHandler.handle { try parent.delete(post: post) }
    }

    private func selectionChanged() {
        selected ? removePost() : addPost()
    }
}

private struct SelectableResults: View {
    @ObservedObject var post: PostViewModel
    @ObservedObject var search: PostQueryViewModel

    var body: some View {
        SearchResults(
            search: search,
            type: "Post",
            text: nil,
            showResultCount: true
        ) { post in
            PostSelectRow(post: post, parent: self.post)
        }
    }
}

struct RelatedPostsEditor: View {
    @ObservedObject var post: PostViewModel
    @ObservedObject var search: PostQueryViewModel

    var body: some View {
        ScrollView {
            VStack {
                ForEach(post.posts) { post in
                    PostSelectRow(post: post, parent: self.post)
                }

                PostSearchControls(search: search)
                    .padding(.horizontal)

                SelectableResults(post: post, search: search)
            }
        }
        .navigationTitle("Related Posts")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RelatedPostsEditor_Previews: PreviewProvider {
    private struct Preview: View {
        @StateObject private var post =
            PostViewModel.preview(id: PreviewPost.test)
        @StateObject private var search = PostQueryViewModel()

        var body: some View {
            NavigationView {
                RelatedPostsEditor(post: post, search: search)
            }
            .loadEntity(post)
            .loadEntity(search)
        }
    }

    static var previews: some View {
        Preview()
            .withErrorHandling()
            .environmentObject(DataSource.preview)
            .environmentObject(ObjectSource.preview)
    }
}

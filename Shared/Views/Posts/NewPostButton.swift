import Minty
import SwiftUI

private struct PostDetailLink: View {
    @EnvironmentObject var data: DataSource

    let id: UUID?

    @Binding var isActive: Bool

    var body: some View {
        if let id = id {
            NavigationLink(
                destination: PostDetail(post: data.state.posts.fetch(id: id)),
                isActive: $isActive
            ) {
                EmptyView()
            }
        }
    }
}

struct NewPostButton: View {
    let onCreated: (() -> Void)?
    let tag: TagViewModel?

    @State private var newPostId: UUID?
    @State private var showingNewPost = false
    @State private var showingEditor = false

    var body: some View {
        Button(action: { showingEditor = true }) {
            Image(systemName: "plus")
        }
        .background {
            PostDetailLink(id: newPostId, isActive: $showingNewPost)
        }
        .sheet(isPresented: $showingEditor) {
            NewPostView(onCreated: onNewPost, tag: tag)
        }
    }

    init(tag: TagViewModel? = nil, onCreated: (() -> Void)? = nil) {
        self.onCreated = onCreated
        self.tag = tag
    }

    private func onNewPost(id: UUID) {
        newPostId = id
        showingNewPost = true

        if let onCreated = onCreated { onCreated() }
    }
}

struct NewPostButton_Previews: PreviewProvider {
    static var previews: some View {
        NewPostButton()
            .withErrorHandling()
            .environmentObject(DataSource.preview)
    }
}

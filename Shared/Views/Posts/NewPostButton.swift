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
    @EnvironmentObject var errorHandler: ErrorHandler

    let onCreated: (() -> Void)?
    let tag: TagViewModel?

    @ObservedObject var post: NewPostViewModel

    @State private var newPostId: UUID?
    @State private var showingNewPost = false
    @State private var showingEditor = false

    var body: some View {
        Button(action: {
            if post.draft != nil {
                showingEditor = true
            }
            else {
                errorHandler.handle {
                    let draft = try await post.createDraft()

                    if let tag = tag {
                        try await draft.add(tag: tag)
                        draft.tags.append(tag)
                    }

                    showingEditor = true
                }
            }
        }) {
            Image(systemName: "plus")
        }
        .loadEntity(post)
        .background {
            if let id = newPostId {
                PostDetailLink(id: id, isActive: $showingNewPost)
            }
        }
        .sheet(isPresented: $showingEditor) {
            if let draft = post.draft {
                PostEditor(post: draft)
                    .onDisappear {
                        if draft.visibility != .draft {
                            newPostId = draft.id
                            post.draft = nil

                            showingNewPost = true

                            if let onCreated = onCreated {
                                onCreated()
                            }
                        }
                    }
            }
        }
    }

    init(
        post: NewPostViewModel,
        tag: TagViewModel? = nil,
        onCreated: (() -> Void)? = nil
    ) {
        self.onCreated = onCreated
        self.tag = tag
        self.post = post
    }
}

struct NewPostButton_Previews: PreviewProvider {
    private struct Preview: View {
        @StateObject private var post = NewPostViewModel()

        var body: some View {
            NewPostButton(post: post)
                .withErrorHandling()
                .environmentObject(DataSource.preview)
        }
    }

    static var previews: some View {
        Preview()
    }
}

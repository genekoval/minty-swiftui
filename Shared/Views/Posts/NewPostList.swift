import Combine
import Minty
import SwiftUI

class NewPostListViewModel: ObservableObject {
    @Published var posts: [PostPreview] = []
    @Published var selection: String?

    let newPost = PassthroughSubject<String, Never>()

    private var newPostCancellable: AnyCancellable?

    init() {
        newPostCancellable = newPost.sink(receiveValue: didCreate)
    }

    private func didCreate(postId: String) {
        var newPost = PostPreview()
        newPost.id = postId

        posts.append(newPost)
        selection = postId
    }
}

struct NewPostList: View {
    @EnvironmentObject var data: DataSource

    @ObservedObject var newPosts: NewPostListViewModel

    @StateObject private var deleted = Deleted()

    var body: some View {
        if !newPosts.posts.isEmpty {
            VStack {
                HStack {
                    Text("Recently Added")
                        .bold()
                        .font(.title2)
                        .padding([.horizontal, .top])
                    Spacer()
                }

                ForEach($newPosts.posts) { post in
                    NavigationLink(
                        destination: PostDetail(
                            id: post.id,
                            repo: data.repo,
                            deleted: deleted,
                            preview: post
                        ),
                        tag: post.id,
                        selection: $newPosts.selection
                    ) {
                        PostRow(post: post.wrappedValue)
                    }
                    .buttonStyle(.plain)
                }
            }
            .onReceive(deleted.$id, perform: didDelete)
        }
    }

    private func didDelete(postId: String?) {
        if let id = postId {
            if let index = newPosts.posts.firstIndex(where: { $0.id == id }) {
                newPosts.posts.remove(at: index)
            }
        }
    }
}

import Combine
import Minty
import SwiftUI

struct NewPostList: View {
    @ObservedObject var newPosts: NewPostListViewModel

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
        }
    }
}

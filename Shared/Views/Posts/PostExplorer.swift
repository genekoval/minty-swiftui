import Minty
import SwiftUI

struct PostExplorer: View {
    @EnvironmentObject var data: DataSource

    @StateObject private var deleted = Deleted()
    @StateObject private var search: PostQueryViewModel

    @State private var newPosts: [PostPreview] = []
    @State private var selection: String?

    var body: some View {
        ScrollView {
            VStack {
                NavigationLink(
                    destination: PostSearch(search: search, deleted: deleted)
                ) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                        Spacer()
                    }
                    .font(.title2)
                }
                .padding(.horizontal)

                recentlyAdded
            }
        }
        .navigationTitle("Posts")
        .toolbar {
            ToolbarItem(placement: .primaryAction) { addButton }
        }
        .onReceive(deleted.$id, perform: didDelete)
    }

    @ViewBuilder
    private var addButton: some View {
        NewPostButton(onCreate: didCreate)
    }

    @ViewBuilder
    private var recentlyAdded: some View {
        if !newPosts.isEmpty {
            VStack {
                HStack {
                    Text("Recently Added")
                        .bold()
                        .font(.title2)
                        .padding([.horizontal, .top])
                    Spacer()
                }

                ForEach($newPosts) { post in
                    NavigationLink(
                        destination: PostDetail(
                            id: post.id,
                            repo: data.repo,
                            deleted: deleted,
                            preview: post
                        ),
                        tag: post.id,
                        selection: $selection
                    ) {
                        PostRow(post: post.wrappedValue)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    init(repo: MintyRepo?) {
        _search = StateObject(wrappedValue: PostQueryViewModel(repo: repo))
    }

    private func didCreate(postId: String) {
        var newPost = PostPreview()
        newPost.id = postId

        newPosts.append(newPost)
        selection = postId
    }

    private func didDelete(postId: String?) {
        if let id = postId {
            if let index = newPosts.firstIndex(where: { $0.id == id }) {
                newPosts.remove(at: index)
            }
        }
    }
}

struct PostExplorer_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PostExplorer(repo: PreviewRepo())
        }
        .environmentObject(DataSource.preview)
        .environmentObject(ObjectSource.preview)
    }
}

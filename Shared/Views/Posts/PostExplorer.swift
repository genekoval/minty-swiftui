import Minty
import SwiftUI

struct PostExplorer: View {
    @EnvironmentObject var data: DataSource

    @StateObject private var newPosts = NewPostListViewModel()
    @StateObject private var search: PostQueryViewModel

    var body: some View {
        PaddedScrollView {
            VStack {
                NavigationLink(
                    destination: PostSearch(search: search)
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
    }

    @ViewBuilder
    private var addButton: some View {
        NewPostButton()
    }

    @ViewBuilder
    private var recentlyAdded: some View {
        NewPostList(newPosts: newPosts)
    }

    init(repo: MintyRepo?) {
        _search = StateObject(wrappedValue: PostQueryViewModel(repo: repo))
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

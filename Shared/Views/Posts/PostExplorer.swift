import Minty
import SwiftUI

struct PostExplorer: View {
    @StateObject private var draft = NewPostViewModel()

    @StateObject private var search = PostQueryViewModel()

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
            }
        }
        .navigationTitle("Posts")
        .toolbar {
            ToolbarItem(placement: .primaryAction) { addButton }
        }
        .prepareSearch(search)
    }

    @ViewBuilder
    private var addButton: some View {
        NewPostButton(post: draft)
    }
}

struct PostExplorer_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PostExplorer()
        }
        .environmentObject(DataSource.preview)
        .environmentObject(ObjectSource.preview)
    }
}

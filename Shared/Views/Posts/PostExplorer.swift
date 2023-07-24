import Minty
import SwiftUI

struct PostExplorer: View {
    @State private var draft: PostViewModel?

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
        .toolbar { addButton }
        .prepareSearch(search)
    }

    @ViewBuilder
    private var addButton: some View {
        NewPostButton(draft: $draft, tag: nil)
    }
}

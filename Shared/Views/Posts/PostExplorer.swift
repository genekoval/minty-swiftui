import Minty
import SwiftUI

struct PostExplorer: View {
    @StateObject private var deleted = Deleted()
    @StateObject private var search: PostQueryViewModel

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
            }
            .padding(.horizontal)
        }
        .navigationTitle("Posts")
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
        .environmentObject(ObjectSource.preview)
    }
}

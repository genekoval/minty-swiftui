import Minty
import SwiftUI

struct PostExplorer: View {
    @EnvironmentObject var data: DataSource

    @StateObject private var deleted = Deleted()
    @StateObject private var search = PostQueryViewModel()
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
        .onAppear { search.repo = data.repo }
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

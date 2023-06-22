import SwiftUI

struct SearchHome: View {
    @EnvironmentObject var data: DataSource

    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: TagSearch()) {
                    HStack {
                        Image(systemName: "tag.fill")
                            .foregroundColor(.green)
                        Text("Tags")
                    }
                }

                NavigationLink(
                    destination: PostExplorer()) {
                    HStack {
                        Image(systemName: "doc.text.image.fill")
                            .foregroundColor(.blue)
                        Text("Posts")
                    }
                }
            }
            .navigationBarTitle("Search")
        }
    }
}

struct SearchHome_Previews: PreviewProvider {
    static var previews: some View {
        SearchHome()
            .withErrorHandling()
            .environmentObject(DataSource.preview)
            .environmentObject(ObjectSource.preview)
    }
}

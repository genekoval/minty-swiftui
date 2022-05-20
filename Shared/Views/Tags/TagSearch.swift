import Minty
import SwiftUI

struct TagSearch: View {
    @StateObject private var query = TagQueryViewModel()

    var body: some View {
        TagHome(query: query)
            .buttonStyle(PlainButtonStyle())
            .navigationTitle("Tags")
            .searchable(text: $query.name)
            .toolbar {
                NewTagButton()
            }
            .prepareSearch(query)
    }
}

struct TagSearch_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TagSearch()
                .withErrorHandling()
                .environmentObject(DataSource.preview)
                .environmentObject(ObjectSource.preview)
        }
    }
}

import Minty
import SwiftUI

struct TagSearch: View {
    @StateObject private var query = TagQueryViewModel()

    var body: some View {
        TagHome(query: query)
            .buttonStyle(PlainButtonStyle())
            .navigationTitle("Tags")
            .searchable(text: $query.name, prompt: "Find or add a tag")
            .prepareSearch(query)
    }
}

import Minty
import SwiftUI

struct TagHome: View {
    @Environment(\.isSearching) var isSearching

    @ObservedObject var query: TagQueryViewModel

    var body: some View {
        PaddedScrollView {
            if isSearching {
                TagSearchResults(search: query)
            }
            else {
                EmptyView()
            }
        }
    }
}

struct TagHome_Previews: PreviewProvider {
    @StateObject private static var query = TagQueryViewModel.preview()

    static var previews: some View {
        TagHome(query: query)
    }
}

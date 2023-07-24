import Minty
import SwiftUI

struct TagHome: View {
    @Environment(\.isSearching) private var isSearching

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

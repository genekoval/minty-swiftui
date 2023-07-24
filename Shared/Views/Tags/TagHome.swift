import Minty
import SwiftUI

struct TagHome: View {
    @Environment(\.isSearching) private var isSearching

    @ObservedObject var query: TagQueryViewModel

    @State private var newTags: [TagViewModel] = []

    var body: some View {
        PaddedScrollView {
            if isSearching {
                TagSearchResults(search: query)
                    .buttonStyle(PlainButtonStyle())
            }
            else if !newTags.isEmpty {
                VStack(alignment: .leading) {
                    Text("Recently Added")
                        .font(.title2)
                        .bold()
                        .padding(.bottom)

                    TagList(tags: $newTags)
                }
                .padding()
            }
            else {
                EmptyView()
            }
        }
        .toolbar {
            NewTagButton { tag in
                withAnimation {
                    newTags.insert(tag, at: 0)
                }
            }
        }
    }
}

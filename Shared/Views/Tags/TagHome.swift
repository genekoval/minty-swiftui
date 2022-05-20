import Minty
import SwiftUI

private struct TagDisplayRow: View {
    let tag: TagViewModel

    var body: some View {
        VStack {
            TagRow(tag: tag)
            Divider()
        }
        .padding(.horizontal)
    }
}

struct TagHome: View {
    @Environment(\.isSearching) var isSearching

    @ObservedObject var query: TagQueryViewModel

    @Binding var selection: UUID?

    var body: some View {
        PaddedScrollView {
            if isSearching {
                TagSearchResults(search: query)
            }
            else {
                VStack {
                    if !query.excluded.isEmpty {
                        HStack {
                            Text("Recently Added")
                                .bold()
                                .font(.title2)
                                .padding()
                            Spacer()
                        }

                        ForEach(query.excluded) { tag in
                            NavigationLink(
                                destination: TagDetail(tag: tag),
                                tag: tag.id,
                                selection: $selection
                            ) {
                                TagDisplayRow(tag: tag)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct TagHome_Previews: PreviewProvider {
    @StateObject private static var query = TagQueryViewModel.preview()
    @State private static var selection: UUID?

    static var previews: some View {
        TagHome(query: query, selection: $selection)
    }
}

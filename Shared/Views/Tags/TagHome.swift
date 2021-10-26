import Minty
import SwiftUI

struct TagHome: View {
    @Environment(\.isSearching) var isSearching
    @ObservedObject var query: TagQueryViewModel
    @Binding var recentlyCreated: [TagPreview]
    @Binding var selection: String?

    var body: some View {
        ScrollView {
            LazyVStack {
                if isSearching {
                    if !query.name.isEmpty {
                        ResultCount(
                            typeSingular: "Tag",
                            typePlural: "Tags",
                            count: query.total,
                            text: query.name
                        )
                    }

                    ForEach(query.hits) { tag in
                        NavigationLink(destination: TagDetail(id: tag.id)) {
                            TagRow(tag: tag)
                        }
                    }

                    if query.resultsAvailable {
                        ProgressView()
                            .onAppear { query.nextPage() }
                            .progressViewStyle(.circular)
                    }
                }
                else {
                    if !recentlyCreated.isEmpty {
                        HStack {
                            Text("Recently Added")
                                .bold()
                                .font(.title2)
                                .padding()
                            Spacer()
                        }

                        ForEach(recentlyCreated) { tag in
                            NavigationLink(
                                destination: TagDetail(id: tag.id),
                                tag: tag.id,
                                selection: $selection
                            ) {
                                TagRow(tag: tag)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct TagHome_Previews: PreviewProvider {
    static var previews: some View {
        TagHome(
            query: TagQueryViewModel(),
            recentlyCreated: .constant([TagPreview]()),
            selection: .constant("")
        )
    }
}

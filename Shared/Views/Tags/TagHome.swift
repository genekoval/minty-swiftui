import Minty
import SwiftUI

private struct TagDisplayRow: View {
    let tag: TagPreview

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

    @Binding var selection: String?

    @StateObject private var deleted = Deleted()

    @State private var deletedTag: String?

    var body: some View {
        ScrollView {
            LazyVStack {
                if isSearching {
                    if !query.name.isEmpty {
                        ResultCount(
                            type: "Tag",
                            count: query.total,
                            text: query.name
                        )
                    }

                    ForEach(query.hits) { tag in
                        NavigationLink(destination: TagDetail(
                            id: tag.id,
                            repo: query.repo,
                            deleted: $deleted.id
                        )) {
                            TagDisplayRow(tag: tag)
                        }
                    }

                    if query.resultsAvailable {
                        ProgressView()
                            .onAppear { query.nextPage() }
                            .progressViewStyle(.circular)
                    }
                }
                else {
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
                                destination: TagDetail(
                                    id: tag.id,
                                    repo: query.repo,
                                    deleted: $deleted.id
                                ),
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
        .onReceive(deleted.$id) { id in
            if let id = id {
                delete(id: id)
            }
        }
    }

    private func delete(id: String) {
        query.remove(id: id)
    }
}

struct TagHome_Previews: PreviewProvider {
    @StateObject private static var query = TagQueryViewModel.preview()
    @State private static var selection: String?

    static var previews: some View {
        TagHome(query: query, selection: $selection)
    }
}

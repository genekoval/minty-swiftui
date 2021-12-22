import SwiftUI

struct SearchResults<Element, QueryType, Content>: View where
    Element: SearchElement, QueryType: Query, Content: View
{
    @ObservedObject var search: Search<Element, QueryType>
    @ObservedObject var deleted: Deleted

    let type: String
    let showResultCount: Bool
    @ViewBuilder let content: (Binding<Element>) -> Content

    var body: some View {
        LazyVStack {
            if showResultCount && search.initialSearch {
                ResultCount(type: type, count: search.total)
            }

            ForEach($search.hits) { content($0) }

            if search.resultsAvailable {
                ProgressView()
                    .progressViewStyle(.circular)
                    .onAppear { search.nextPage() }
            }
        }
        .buttonStyle(.plain)
        .onReceive(deleted.$id) { id in
            if let id = id {
                search.remove(id: id)
            }
        }
    }
}

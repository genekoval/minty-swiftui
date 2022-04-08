import SwiftUI

struct SearchResults<Element, QueryType, Content>: View where
    Element: SearchElement, QueryType: Query, Content: View
{
    @ObservedObject var search: Search<Element, QueryType>

    let type: String
    let text: String?
    let showResultCount: Bool
    @ViewBuilder let content: (Element) -> Content

    var body: some View {
        LazyVStack {
            if showResultCount && search.initialSearch {
                ResultCount(type: type, count: search.total, text: text)
            }

            ForEach(search.hits) { content($0) }

            if search.resultsAvailable {
                ProgressView()
                    .progressViewStyle(.circular)
                    .onAppear { search.nextPage() }
            }
        }
        .buttonStyle(.plain)
    }
}

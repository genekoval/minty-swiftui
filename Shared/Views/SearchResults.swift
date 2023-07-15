import SwiftUI

struct SearchResults<Element, QueryType, Content, SideContent>: View where
    Element: IdentifiableEntity,
    QueryType: Query,
    Content: View,
    SideContent: View
{
    @ObservedObject private var search: Search<Element, QueryType>

    private let type: String
    private let showResultCount: Bool
    private let content: (Element) -> Content
    private let sideContent: SideContent

    var body: some View {
        LazyVStack {
            if showResultCount && search.resultsAvailable {
                ResultCount<SideContent>(
                    type: type,
                    count: search.total,
                    sideContent: { sideContent }
                )
            }

            ForEach(search.hits) { content($0) }

            if !search.complete {
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(.circular)
                        .onAppear {
                            Task {
                                await search.nextPage()
                            }
                        }
                    Spacer()
                }
            }
        }
        .buttonStyle(.plain)
    }

    init(
        search: Search<Element, QueryType>,
        type: String,
        showResultCount: Bool = false,
        content: @escaping (Element) -> Content
    ) where SideContent == EmptyView {
        self.init(
            search: search,
            type: type,
            showResultCount: showResultCount,
            content: content,
            sideContent: { EmptyView() }
        )
    }

    init(
        search: Search<Element, QueryType>,
        type: String,
        showResultCount: Bool = false,
        content: @escaping (Element) -> Content,
        @ViewBuilder sideContent: () -> SideContent
    ) {
        self.search = search
        self.type = type
        self.showResultCount = showResultCount
        self.content = content
        self.sideContent = sideContent()
    }
}

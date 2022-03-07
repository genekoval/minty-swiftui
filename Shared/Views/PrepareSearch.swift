import SwiftUI

private struct PrepareSearch: ViewModifier {
    @EnvironmentObject var data: DataSource
    @EnvironmentObject var errorHandler: ErrorHandler

    let search: SearchObject

    func body(content: Content) -> some View {
        content
            .onAppear {
                search.prepare(repo: data.repo, errorHandler: errorHandler)
            }
    }
}

extension View {
    func prepareSearch(_ search: SearchObject) -> some View {
        modifier(PrepareSearch(search: search))
    }
}

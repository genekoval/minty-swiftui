import SwiftUI

private struct PrepareSearch: ViewModifier {
    @EnvironmentObject var data: DataSource
    @EnvironmentObject var errorHandler: ErrorHandler

    let search: SearchObject

    func body(content: Content) -> some View {
        content
            .onFirstAppearance {
                search.prepare(app: data, errorHandler: errorHandler)
            }
    }
}

extension View {
    func prepareSearch(_ search: SearchObject) -> some View {
        modifier(PrepareSearch(search: search))
    }
}

import SwiftUI

private struct PrepareSearch: ViewModifier {
    @EnvironmentObject var data: DataSource
    @EnvironmentObject var errorHandler: ErrorHandler

    let search: SearchObject

    @State private var prepared = false

    func body(content: Content) -> some View {
        content
            .onAppear {
                prepare()
            }
    }

    private func prepare() {
        if !prepared {
            search.prepare(repo: data.repo, errorHandler: errorHandler)
            prepared = true
        }
    }
}

extension View {
    func prepareSearch(_ search: SearchObject) -> some View {
        modifier(PrepareSearch(search: search))
    }
}

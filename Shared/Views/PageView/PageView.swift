import Minty
import SwiftUI

struct PageView<Page: View>: View {
    var pages: [Page]

    @Binding var currentPage: Int

    var body: some View {
        PageViewController(pages: pages, currentPage: $currentPage)
    }
}

struct PageView_Previews: PreviewProvider {
    @State private static var currentPage = 0

    static var previews: some View {
        PageView(
            pages: Post.preview(id: "sand dune")
                .objects.map { ObjectViewer(object: $0) },
            currentPage: $currentPage
        )
        .environmentObject(ObjectSource.preview)
        .environmentObject(Overlay())
    }
}

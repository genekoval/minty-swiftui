import Minty
import SwiftUI

struct PageView<Page: View>: View {
    var pages: [Page]

    @Binding var currentPage: Int

    var body: some View {
        PageViewController(pages: pages, currentPage: $currentPage)
    }
}

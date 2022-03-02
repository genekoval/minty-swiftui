import SwiftUI

struct PaddedScrollView<Content>: View where Content : View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView {
            content()
        }
        .playerSpacing()
    }
}

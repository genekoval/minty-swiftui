import SwiftUI

struct Row<Content>: View where Content : View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack {
            content()
            Divider()
        }
    }
}

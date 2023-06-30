import SwiftUI

struct TagLink: View {
    let tag: TagViewModel

    var body: some View {
        NavigationLink(destination: TagHost(tag: tag)) {
            TagRow(tag: tag)
        }
        .buttonStyle(.plain)
    }
}

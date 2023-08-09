import Minty
import SwiftUI

struct TagRow: View {
    @ObservedObject var tag: TagViewModel

    var body: some View {
        NavigationLink(destination: TagHost(tag: tag)) {
            HStack {
                Text(tag.name)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

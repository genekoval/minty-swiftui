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
            .background {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

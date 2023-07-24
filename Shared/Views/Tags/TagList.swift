import Minty
import SwiftUI

struct TagList: View {
    @Binding var tags: [TagViewModel]

    var body: some View {
        ForEach(tags) {
            TagRow(tag: $0)
            Divider()
        }
        .onAppear {
            withAnimation {
                tags.removeAll(where: { $0.deleted })
            }
        }
        .onReceive(Tag.deleted) { id in
            withAnimation {
                _ = tags.remove(id: id)
            }
        }
    }
}

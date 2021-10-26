import Minty
import SwiftUI

struct TagRow: View {
    var tag: TagPreview

    var body: some View {
        VStack {
            HStack {
                Text(tag.name)
                Spacer()
            }

            Divider()
        }
        .padding(.horizontal)
    }
}

struct TagRow_Previews: PreviewProvider {
    @State private static var tag = TagPreview.preview(id: "1")

    static var previews: some View {
        TagRow(tag: tag)
    }
}

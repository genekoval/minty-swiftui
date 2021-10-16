import Minty
import SwiftUI

struct TagRow: View {
    @Binding var tag: TagPreview

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
    @State private static var tag: TagPreview = {
        var tag = TagPreview()

        tag.name = "Test Tag"

        return tag
    }()

    static var previews: some View {
        TagRow(tag: $tag)
    }
}

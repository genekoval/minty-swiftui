import Minty
import SwiftUI

struct TagRow: View {
    var tag: TagPreview

    var body: some View {
        HStack {
            Text(tag.name)
            Spacer()
        }
    }
}

struct TagRow_Previews: PreviewProvider {
    static private let tag: TagPreview = {
        var tag = TagPreview()

        tag.name = "Test Tag"

        return tag
    }()

    static var previews: some View {
        TagRow(tag: tag)
    }
}

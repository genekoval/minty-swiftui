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
    static var previews: some View {
        TagRow(tag: TagPreview.preview(id: "1"))
            .padding(.horizontal)
    }
}

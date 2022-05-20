import Minty
import SwiftUI

struct TagRow: View {
    @ObservedObject var tag: TagViewModel

    var body: some View {
        HStack {
            Text(tag.name)
            Spacer()
        }
    }
}

struct TagRow_Previews: PreviewProvider {
    static var previews: some View {
        TagRow(tag: TagViewModel.preview(id: PreviewTag.helloWorld))
            .padding(.horizontal)
    }
}

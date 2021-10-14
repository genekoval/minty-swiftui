import SwiftUI

struct TagDetail: View {
    var id: String

    var body: some View {
        Text("Tag ID: \(id)")
    }
}

struct TagDetail_Previews: PreviewProvider {
    static var previews: some View {
        TagDetail(id: "1")
    }
}

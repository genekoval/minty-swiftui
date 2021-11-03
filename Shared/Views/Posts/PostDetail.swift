import SwiftUI

struct PostDetail: View {
    private let id: String

    @Binding var deleted: String?

    var body: some View {
        Text(id)
    }

    init(id: String, deleted: Binding<String?>) {
        self.id = id
        _deleted = deleted
    }
}

struct PostDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PostDetail(id: "1", deleted: .constant(""))
        }
    }
}

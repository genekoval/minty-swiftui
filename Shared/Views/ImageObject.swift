import SwiftUI

struct ImageObject<Content: View>: View {
    @EnvironmentObject var objects: ObjectSource

    let id: String?
    @ViewBuilder let placeholder: Content

    @State private var imageData: Data?

    var body: some View {
        AsyncImage(url: objects.url(for: id)) { image in
            image.resizable()
        } placeholder: {
            placeholder
        }
    }
}

struct ImageObject_Previews: PreviewProvider {
    static var previews: some View {
        ImageObject(id: "sand dune.jpg") {
            ProgressView()
        }
        .environmentObject(ObjectSource.preview)
    }
}

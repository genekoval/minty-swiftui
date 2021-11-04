import SwiftUI

@MainActor
struct ImageObject<Content: View>: View {
    @EnvironmentObject var objects: ObjectSource

    let id: String?
    @ViewBuilder let fallback: Content

    @State private var imageData: Data?

    var body: some View {
        if let objectId = id {
            if let data = imageData {
                if let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                }
                else {
                    fallback
                }
            }
            else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .task {
                        imageData = await objects.data(for: objectId)
                    }
            }
        }
        else {
            fallback
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

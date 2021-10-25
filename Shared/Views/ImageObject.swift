import SwiftUI

@MainActor
struct ImageObject<Content: View>: View {
    @EnvironmentObject var objects: ObjectSource
    let objectId: String
    @ViewBuilder let content: Content

    @State private var imageData: Data?

    var body: some View {
        if let data = imageData {
            if let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
            }
            else {
                content
            }
        }
        else {
            content
                .task {
                    imageData = await objects.data(for: objectId)
                }
        }
    }
}

struct ImageObject_Previews: PreviewProvider {
    static var previews: some View {
        ImageObject(objectId: "wikipedia.png") {
            ProgressView()
        }
        .environmentObject(ObjectSource.preview)
    }
}

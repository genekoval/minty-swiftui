import Minty
import SwiftUI

private struct NoPreview: View {
    let type: String

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: "doc")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
            Text(type)
                .font(.caption)
        }
        .foregroundColor(.secondary)
    }
}

struct PreviewImage: View {
    let previewId: String?
    let mimeType: String

    var body: some View {
        ImageObject(id: previewId) {
            NoPreview(type: mimeType)
        }
    }

    init(previewId: String?, mimeType: String) {
        self.previewId = previewId
        self.mimeType = mimeType
    }

    init(object: ObjectPreview) {
        self.init(previewId: object.previewId, mimeType: object.mimeType)
    }
}

struct PreviewImage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PreviewImage(object: ObjectPreview.preview(id: "sand dune.jpg"))
            PreviewImage(object: ObjectPreview.preview(id: "empty"))
        }
        .frame(width: 100)
        .environmentObject(ObjectSource.preview)
        .previewLayout(.sizeThatFits)
    }
}

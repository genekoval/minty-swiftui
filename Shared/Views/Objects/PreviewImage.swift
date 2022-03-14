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

private struct PreviewBadge: View {
    private let mimeType: MimeType

    @ViewBuilder
    private var badge: some View {
        switch (mimeType.type) {
        case "audio":
            Image(systemName: "music.note")
        case "video":
            Image(systemName: "play.fill")
        default:
            EmptyView()
        }
    }

    var body: some View {
        badge
            .font(.title)
            .foregroundColor(.white)
            .shadow(color: .black, radius: 1, x: 0, y: 1)
            .padding(8)
    }

    init(type: String) {
        self.mimeType = MimeType(type)
    }
}

struct PreviewImage: View {
    let previewId: String?
    let mimeType: String

    var body: some View {
        ImageObject(id: previewId) { image in
            image
                .overlay(alignment: .bottomTrailing) {
                    PreviewBadge(type: mimeType)
                }
        } placeholder: {
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

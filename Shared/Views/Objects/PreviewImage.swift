import Minty
import SwiftUI

private struct NoPreview: View {
    let mimeType: String

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: "doc")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50)
            Text(mimeType)
                .font(.caption)
        }
        .foregroundColor(.secondary)
    }
}

private struct PreviewBadge: View {
    let type: String

    @ViewBuilder
    private var badge: some View {
        switch type {
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
}

struct PreviewImage: View {
    let previewId: UUID?
    let type: String
    let subtype: String

    var body: some View {
        ImageObject(id: previewId) { image in
            image
                .overlay(alignment: .bottomTrailing) {
                    PreviewBadge(type: type)
                }
        } placeholder: {
            NoPreview(mimeType: "\(type)/\(subtype)")
        }
    }

    init(previewId: UUID?, type: String, subtype: String) {
        self.previewId = previewId
        self.type = type
        self.subtype = subtype
    }

    init(object: ObjectPreview) {
        self.init(
            previewId: object.previewId,
            type: object.type,
            subtype: object.subtype
        )
    }
}

struct PreviewImage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PreviewImage(
                object: ObjectPreview.preview(id: PreviewObject.sandDune)
            )
            PreviewImage(object: ObjectPreview.preview(id: PreviewObject.empty))
        }
        .frame(width: 100)
        .environmentObject(ObjectSource.preview)
        .previewLayout(.sizeThatFits)
    }
}

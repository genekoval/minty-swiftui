import Minty
import SwiftUI

private struct LinkIcon: View {
    var body: some View {
        Image(systemName: "link")
            .foregroundColor(.secondary)
    }
}

@MainActor
struct SourceLink: View {
    var source: Source

    var body: some View {
        HStack {
            if let objectId = source.icon {
                ImageObject(objectId: objectId) {
                    LinkIcon()
                }
                .aspectRatio(contentMode: .fit)
                .frame(width: 15)
            }
            else {
                LinkIcon()
            }

            Link(destination: URL(string: source.url)!) {
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(source.url)
                }
            }
        }
        .font(.caption)
    }
}

struct SourceLink_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SourceLink(source: Source.preview(id: "1"))
            SourceLink(source: Source.preview(id: "2"))
        }
        .environmentObject(ObjectSource.preview)
    }
}
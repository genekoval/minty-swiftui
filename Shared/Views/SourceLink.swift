import Minty
import SwiftUI

struct SourceLink: View {
    var source: Source

    var body: some View {
        HStack {
            ImageObject(id: source.icon) {
                Image(systemName: "link")
                    .foregroundColor(.secondary)
            }
            .aspectRatio(contentMode: .fit)
            .frame(width: 15)

            Link(destination: source.url) {
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(source.url.absoluteString)
                }
            }
        }
        .font(.caption)
        .contextMenu {
            Button {
                UIPasteboard.general.string = source.url.absoluteString
            } label: {
                Label("Copy Link", systemImage: "doc.on.doc")
            }

            ShareLink(item: source.url)
        } preview: {
            VStack(alignment: .leading, spacing: 10) {
                Text(source.url.host!)
                    .bold()

                Text(source.url.absoluteString)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 30)
        }
    }
}

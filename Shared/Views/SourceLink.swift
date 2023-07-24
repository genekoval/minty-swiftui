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

            Link(destination: url) {
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(source.url)
                }
            }
        }
        .font(.caption)
        .contextMenu {
            Button {
                UIPasteboard.general.string = source.url
            } label: {
                Label("Copy Link", systemImage: "doc.on.doc")
            }

            ShareLink(item: url)
        } preview: {
            VStack(alignment: .leading, spacing: 10) {
                Text(url.host!)
                    .bold()

                Text(url.absoluteString)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 30)
        }
    }

    private var url: URL {
        URL(string: source.url)!
    }
}

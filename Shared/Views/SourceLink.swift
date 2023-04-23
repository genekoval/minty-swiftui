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
            SourceLink(source: Source.preview(id: 1))
            SourceLink(source: Source.preview(id: 2))
        }
        .environmentObject(ObjectSource.preview)
    }
}

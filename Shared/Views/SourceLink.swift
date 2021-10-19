import Minty
import SwiftUI

struct SourceLink: View {
    var source: Source

    var body: some View {
        HStack {
            Image(systemName: "link")
                .foregroundColor(.secondary)

            Link(destination: URL(string: source.url)!) {
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(source.url)
                }
            }
        }
    }
}

struct SourceLink_Previews: PreviewProvider {
    static var previews: some View {
        SourceLink(source: Source.preview(id: "1"))
    }
}

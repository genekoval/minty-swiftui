import Minty
import SwiftUI

struct PostRow: View {
    var post: PostPreview

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                ImageObject(id: post.previewId) {
                    Image(systemName: "text.justifyleft")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
                .frame(width: 100, height: 100)

                VStack(alignment: .leading) {
                    Spacer(minLength: 1)

                    if let title = post.title {
                        Text(title)
                    }
                    else {
                        Text("Untitled")
                            .foregroundColor(.secondary)
                            .italic()
                    }

                    Spacer()

                    HStack(spacing: 20) {
                        Label(
                            "\(post.objectCount)",
                            systemImage: "doc"
                        )
                        Label(
                            "\(post.commentCount)",
                            systemImage: "text.bubble"
                        )
                        Label(
                            "\(post.dateCreated.relative(.short))",
                            systemImage: "clock"
                        )
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }

            Divider()
        }
        .padding([.horizontal, .top], 5)
    }
}

struct PostRow_Previews: PreviewProvider {
    private static let posts = [
        "untitled",
        "sand dune",
        "test"
    ]

    static var previews: some View {
        ScrollView {
            VStack {
                ForEach(posts, id: \.self) { post in
                    PostRow(post: PostPreview.preview(id: post))
                }
            }
        }
        .environmentObject(ObjectSource.preview)
    }
}

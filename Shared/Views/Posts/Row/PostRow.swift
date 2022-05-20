import Minty
import SwiftUI

struct PostRow: View {
    @ObservedObject var post: PostViewModel

    var body: some View {
        HStack(alignment: .top) {
            preview

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
                        "\(post.created.relative(.short))",
                        systemImage: "clock"
                    )
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding([.horizontal, .top], 5)
    }

    @ViewBuilder
    private var preview: some View {
        PostRowPreview(object: post.preview)
            .frame(width: 100, height: 100)
    }
}

struct PostRow_Previews: PreviewProvider {
    private static let posts = [
        PreviewPost.untitled,
        PreviewPost.sandDune,
        PreviewPost.test
    ]

    static var previews: some View {
        ScrollView {
            VStack {
                ForEach(posts, id: \.self) { post in
                    PostRow(post: PostViewModel.preview(id: post))
                }
            }
        }
        .environmentObject(ObjectSource.preview)
    }
}

import Minty
import SwiftUI

struct PostRow: View {
    @ObservedObject var post: PostViewModel

    var body: some View {
        HStack(alignment: .top) {
            preview

            VStack(alignment: .leading) {
                Spacer(minLength: 1)
                title
                Spacer()
                badges
            }

            Spacer()
        }
        .background {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .padding([.horizontal, .vertical], 5)
    }

    @ViewBuilder
    private var badges: some View {
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

    @ViewBuilder
    private var preview: some View {
        PostRowPreview(object: post.preview)
            .frame(width: 100, height: 100)
    }

    @ViewBuilder
    private var title: some View {
        if let title = post.title {
            Text(title)
        }
        else {
            Text("Untitled")
                .italic()
                .foregroundColor(.secondary)
        }
    }
}

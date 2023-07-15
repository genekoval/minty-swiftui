import Minty
import SwiftUI

struct PostRow: View {
    @EnvironmentObject private var errorHandler: ErrorHandler

    @ObservedObject var post: PostViewModel

    @State private var deletePresented = false

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
        .background {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .padding([.horizontal, .vertical], 5)
        .contextMenu {
            ShareLink(item: post.id.uuidString)
            Divider()
            Button(role: .destructive, action: { deletePresented = true} ) {
                Label("Delete", systemImage: "trash")
            }
        }
        .deleteConfirmation("this post", isPresented: $deletePresented ) {
            errorHandler.handle {
                try await post.delete()
            }
        }
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
                    VStack {
                        PostRow(post: PostViewModel.preview(id: post))
                        Divider()
                    }
                }
            }
        }
        .withErrorHandling()
        .environmentObject(DataSource.preview)
        .environmentObject(ObjectSource.preview)
    }
}

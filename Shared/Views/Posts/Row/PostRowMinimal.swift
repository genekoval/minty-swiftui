import Minty
import SwiftUI

struct PostRowMinimal: View {
    @ObservedObject var post: PostViewModel

    var body: some View {
        HStack {
            PostRowPreview(object: post.preview)
                .frame(width: 50, height: 50)

            if let title = post.title {
                Text(title)
                    .lineLimit(1)
            }
            else {
                Text("Untitled")
                    .italic()
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

struct PostRowMinimalContainer: View {
    @EnvironmentObject var data: DataSource

    let post: PostPreview

    var body: some View {
        PostRowMinimal(post: data.state.posts.fetch(for: post))
    }
}

struct PostRowMinimal_Previews: PreviewProvider {
    static var previews: some View {
        PostRowMinimalContainer(
            post: PostPreview.preview(id: PreviewPost.sandDune)
        )
            .environmentObject(DataSource.preview)
            .environmentObject(ObjectSource.preview)
    }
}

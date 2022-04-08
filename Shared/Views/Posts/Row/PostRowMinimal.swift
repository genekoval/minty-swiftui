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
        PostRowMinimal(post: data.post(for: post))
    }
}

struct PostRowMinimal_Previews: PreviewProvider {
    static var previews: some View {
        PostRowMinimalContainer(post: PostPreview.preview(id: "sand dune"))
            .environmentObject(DataSource.preview)
            .environmentObject(ObjectSource.preview)
    }
}
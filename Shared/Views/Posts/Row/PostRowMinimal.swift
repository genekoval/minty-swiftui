import Minty
import SwiftUI

struct PostRowMinimal: View {
    let post: PostPreview

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

struct PostRowMinimal_Previews: PreviewProvider {
    static var previews: some View {
        PostRowMinimal(post: PostPreview.preview(id: "sand dune"))
            .environmentObject(ObjectSource.preview)
    }
}

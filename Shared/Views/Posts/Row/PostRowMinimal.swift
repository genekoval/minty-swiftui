import Minty
import SwiftUI

struct PostRowMinimal: View {
    @ObservedObject var post: PostViewModel

    var body: some View {
        HStack {
            PostRowPreview(object: post.preview)
                .frame(width: 50, height: 50)

            if post.title.isEmpty {
                Text("Untitled")
                    .italic()
                    .foregroundColor(.secondary)
            }
            else {
                Text(post.title)
                    .lineLimit(1)
            }

            Spacer()
        }
    }
}

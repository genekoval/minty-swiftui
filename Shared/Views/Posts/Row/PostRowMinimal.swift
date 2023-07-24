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

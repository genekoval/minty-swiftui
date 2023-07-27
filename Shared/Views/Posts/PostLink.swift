import SwiftUI

struct PostLink: View {
    let post: PostViewModel

    var body: some View {
        NavigationLink(destination: PostHost(post: post)) {
            PostRow(post: post)
                .contextMenu(for: post)
        }
        .buttonStyle(.plain)
    }
}

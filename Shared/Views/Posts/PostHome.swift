import SwiftUI

struct PostHome: View {
    var body: some View {
        PaddedScrollView {
            PostSearch {
                PostLink(post: $0)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Posts")
        .toolbar { NewPostButton() }
    }
}

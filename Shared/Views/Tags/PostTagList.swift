import SwiftUI

struct PostTagList: View {
    @ObservedObject var post: PostViewModel

    var body: some View {
        PaddedScrollView {
            VStack(alignment: .leading) {
                Text(post.tags.countOf(type: "Tag"))
                    .bold()
                    .font(.headline)
                    .padding(.bottom)

                ForEach(post.tags) {
                    TagRow(tag: $0)
                    Divider()
                }
            }
            .padding()

        }
        .navigationTitle("Tags")
        .navigationBarTitleDisplayMode(.inline)
    }
}

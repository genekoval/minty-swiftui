import SwiftUI

struct TagList: View {
    @ObservedObject var post: PostViewModel

    var body: some View {
        PaddedScrollView {
            VStack(alignment: .leading) {
                Text(post.tags.countOf(type: "Tag"))
                    .bold()
                    .font(.headline)
                    .padding(.bottom)

                ForEach(post.tags) { tag in
                    VStack {
                        NavigationLink(destination: TagHost(tag: tag)) {
                            HStack {
                                TagRow(tag: tag)
                                Spacer()
                            }
                        }
                        .buttonStyle(PlainButtonStyle())

                        Divider()
                    }
                }
            }
            .padding()

        }
        .navigationTitle("Tags")
        .navigationBarTitleDisplayMode(.inline)
    }
}

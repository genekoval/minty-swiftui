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

struct TagList_Previews: PreviewProvider {
    private struct Preview: View {
        @StateObject private var post =
            PostViewModel.preview(id: PreviewPost.test)

        var body: some View {
            NavigationView {
                TagList(post: post)
            }
        }
    }

    static var previews: some View {
        Preview()
            .environmentObject(DataSource.preview)
            .environmentObject(ObjectSource.preview)
    }
}

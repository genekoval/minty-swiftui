import Minty
import SwiftUI

struct PostDetail: View {
    @Binding var deleted: String?

    @StateObject private var post: PostViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if let title = post.title {
                    Text(title)
                        .bold()
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let description = post.description {
                    Text(description)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Timestamp(
                    prefix: "Posted",
                    systemImage: "clock",
                    date: post.created
                )

                if post.created != post.modified {
                    Timestamp(
                        prefix: "Last modified",
                        systemImage: "pencil",
                        date: post.modified
                    )
                }

                if post.tags.count > 1 {
                    NavigationLink(destination: TagList(post: post)) {
                        Label(
                            post.tags.countOf(type: "Tag"),
                            systemImage: "tag"
                        )
                        .font(.caption)
                    }
                }
                else if let tag = post.tags.first {
                    NavigationLink( destination: TagDetail(
                        id: tag.id,
                        repo: post.repo,
                        deleted: post.deletedTag
                    )) {
                        Label(tag.name, systemImage: "tag")
                            .font(.caption)
                    }
                }

                if !post.objects.isEmpty {
                    Label(
                        post.objects.countOf(type: "Object"),
                        systemImage: "doc"
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 10)

                    ObjectGrid(objects: post.objects)
                }
            }
            .padding()
        }
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
    }

    init(id: String, repo: MintyRepo?, deleted: Binding<String?>) {
        _post = StateObject(wrappedValue: PostViewModel(id: id, repo: repo))
        _deleted = deleted
    }
}

struct PostDetail_Previews: PreviewProvider {
    private static let posts = [
        "test",
        "sand dune",
        "untitled"
    ]

    static var previews: some View {
        Group {
            ForEach(posts, id: \.self) { post in
                NavigationView {
                    PostDetail(
                        id: post,
                        repo: PreviewRepo(),
                        deleted: .constant("")
                    )
                }
            }
        }
        .environmentObject(DataSource.preview)
        .environmentObject(ObjectSource.preview)
    }
}

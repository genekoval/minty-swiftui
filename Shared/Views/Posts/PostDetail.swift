import Minty
import SwiftUI

struct PostDetail: View {
    @Environment(\.dismiss) var dismiss

    @ObservedObject var post: PostViewModel

    @State private var showingEditor = false

    var body: some View {
        PaddedScrollView {
            postInfo
            controls
            comments
        }
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
        .loadEntity(post)
        .onAppear {
            if post.deleted { dismiss() }
        }
        .onReceive(post.$deleted) { if $0 { dismiss() } }
        .sheet(isPresented: $showingEditor) { PostEditor(post: post) }
        .toolbar { Button("Edit") { showingEditor = true } }
    }

    @ViewBuilder
    private var comments: some View {
        VStack(spacing: 0) {
            ForEach(post.comments) { comment in
                CommentRow(comment: comment, post: post)
            }
        }
    }

    @ViewBuilder
    private var commentCount: some View {
        if !post.comments.isEmpty {
            Label(
                post.comments.countOf(type: "Comment"),
                systemImage: "text.bubble"
            )
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private var controls: some View {
        HStack {
            Spacer()
            NewCommentButton(post: post)
            Spacer()
        }
        .padding(.vertical, 5)
    }

    @ViewBuilder
    private var created: some View {
        Timestamp(
            prefix: "Posted",
            systemImage: "clock",
            date: post.created
        )
    }

    @ViewBuilder
    private var description: some View {
        if let description = post.description {
            Text(description)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var metadata: some View {
        VStack(alignment: .leading, spacing: 10) {
            created
            modified
            objectCount
            commentCount
            tags
        }
        .padding()
    }

    @ViewBuilder
    private var modified: some View {
        if post.created != post.modified {
            Timestamp(
                prefix: "Last modified",
                systemImage: "pencil",
                date: post.modified
            )
        }
    }

    @ViewBuilder
    private var objects: some View {
        if !post.objects.isEmpty {
            ObjectGrid(provider: post)
        }
    }

    @ViewBuilder
    private var objectCount: some View {
        if !post.objects.isEmpty {
            Label(post.objects.countOf(type: "Object"), systemImage: "doc")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private var posts: some View {
        if !post.posts.isEmpty {
            VStack {
                ForEach(post.posts) { post in
                    NavigationLink(
                        destination: PostDetailContainer(id: post.id)
                    ) {
                        PostRowMinimalContainer(post: post)
                    }

                    Divider()
                }
                .buttonStyle(.plain)
            }
            .padding([.horizontal, .top])
        }
    }

    @ViewBuilder
    private var postInfo: some View {
        VStack(alignment: .leading, spacing: 10) {
            title
            description
        }
        .padding()

        objects
        posts
        metadata
    }

    @ViewBuilder
    private var tags: some View {
        if post.tags.count > 1 {
            NavigationLink(destination: TagList(post: post)) {
                Label(post.tags.countOf(type: "Tag"), systemImage: "tag")
                    .font(.caption)
            }
        }
        else if let tag = post.tags.first {
            NavigationLink(destination: TagDetail(tag: tag, repo: post.repo)) {
                Label(tag.name, systemImage: "tag")
                    .font(.caption)
            }
        }
    }

    @ViewBuilder
    private var title: some View {
        if let title = post.title {
            Text(title)
                .bold()
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct PostDetailContainer: View {
    @EnvironmentObject var data: DataSource

    let id: String

    var body: some View {
        PostDetail(post: data.post(id: id))
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
                    PostDetailContainer(id: post)
                }
            }
        }
        .withErrorHandling()
        .environmentObject(DataSource.preview)
        .environmentObject(ObjectSource.preview)
        .environmentObject(Overlay())
    }
}

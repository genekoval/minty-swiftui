import Minty
import SwiftUI

struct PostDetail: View {
    @Environment(\.dismiss) var dismiss

    @Binding var preview: PostPreview

    @StateObject private var post: PostViewModel

    @State private var showingEditor = false

    var body: some View {
        ScrollView {
            postInfo
        }
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(post.$preview) { preview in
            self.preview = preview
        }
        .onAppear { if post.deleted { dismiss() } }
        .onReceive(post.$deleted) { if $0 { dismiss() } }
        .sheet(isPresented: $showingEditor) { PostEditor(post: post) }
        .toolbar { Button("Edit") { showingEditor = true } }
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
            ObjectGrid(objects: post.objects)
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
    private var postInfo: some View {
        VStack(alignment: .leading, spacing: 10) {
            title
            description
        }
        .padding()

        objects
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

    init(
        id: String,
        repo: MintyRepo?,
        preview: Binding<PostPreview>
    ) {
        _preview = preview
        _post = StateObject(wrappedValue: PostViewModel(
            id: id,
            repo: repo,
            preview: preview.wrappedValue
        ))
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
                        preview: .constant(PostPreview.preview(id: post))
                    )
                }
            }
        }
        .environmentObject(DataSource.preview)
        .environmentObject(ObjectSource.preview)
    }
}

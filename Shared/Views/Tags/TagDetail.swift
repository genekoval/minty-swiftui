import Minty
import SwiftUI

struct TagDetail: View {
    @Environment(\.dismiss) var dismiss

    @ObservedObject var deleted: Deleted

    @StateObject private var tag: TagViewModel
    @StateObject private var recentPosts: PostQueryViewModel
    @StateObject private var search: PostQueryViewModel
    @StateObject private var deletedPost = Deleted()

    @State private var showingEditor = false

    @ViewBuilder
    private var aliases: some View {
        if !tag.aliases.isEmpty {
            VStack(alignment: .leading, spacing: 5) {
                ForEach(tag.aliases, id: \.self) { alias in
                    Text(alias)
                        .bold()
                        .font(.footnote)
                }
            }
            .padding(.leading, 10)
        }
    }

    var body: some View {
        ScrollView {
            tagInfo
            controls

            posts
        }
        .navigationTitle(tag.name)
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(deleted.$id) { id in
            if let id = id {
                if id == tag.id {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingEditor) { TagEditor(tag: tag) }
        .toolbar {
            Button("Edit") {
                showingEditor.toggle()
            }
        }
    }

    @ViewBuilder
    private var controls: some View {
        HStack {
            Spacer()
            searchButton
            Spacer()
        }
        .padding(.vertical, 5)
    }

    @ViewBuilder
    private var created: some View {
        Timestamp(
            prefix: "Created",
            systemImage: "calendar",
            date: tag.dateCreated
        )
    }

    @ViewBuilder
    private var description: some View {
        if let description = tag.description {
            Text(description)
        }
    }

    @ViewBuilder
    private var metadata: some View {
        sources
        created
        postCount
    }

    @ViewBuilder
    private var name: some View {
        HStack {
            Text(tag.name)
                .bold()
                .font(.title)
            Spacer()
        }
    }

    @ViewBuilder
    private var posts: some View {
        if tag.postCount > 0 {
            Divider()

            PostSearchResults(
                search: recentPosts,
                deleted: deletedPost,
                showResultCount: false
            )
        }
    }

    @ViewBuilder
    private var postCount: some View {
        Label(
            "\(tag.postCount) Post\(tag.postCount == 1 ? "" : "s")",
            systemImage: "doc.text.image"
        )
        .font(.caption)
        .foregroundColor(.secondary)
    }

    @ViewBuilder
    private var searchButton: some View {
        NavigationLink(
            destination: PostSearch(search: search, deleted: deleted)
        ) {
            Image(systemName: "magnifyingglass")
        }
    }

    @ViewBuilder
    private var sources: some View {
        if !tag.sources.isEmpty {
            ForEach(tag.sources) { SourceLink(source: $0) }
        }
    }

    @ViewBuilder
    private var tagInfo: some View {
        VStack(alignment: .leading, spacing: 10) {
            name
            aliases
            description
            metadata
        }
        .padding()
    }

    init(tag: TagPreview, repo: MintyRepo?, deleted: Deleted) {
        self.deleted = deleted
        _tag = StateObject(wrappedValue: TagViewModel(
            id: tag.id,
            repo: repo,
            deleted: deleted
        ))
        _recentPosts = StateObject(wrappedValue: PostQueryViewModel(
            repo: repo,
            tag: tag,
            searchNow: true
        ))
        _search = StateObject(wrappedValue: PostQueryViewModel(
            repo: repo,
            tag: tag
        ))
    }
}

struct TagDetail_Previews: PreviewProvider {
    private static let tag = TagPreview.preview(id: "1")

    @StateObject private static var deleted = Deleted()

    static var previews: some View {
        NavigationView {
            TagDetail(tag: tag, repo: PreviewRepo(), deleted: deleted)
        }
        .environmentObject(DataSource.preview)
        .environmentObject(ObjectSource.preview)
    }
}

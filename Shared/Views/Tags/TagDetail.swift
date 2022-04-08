import Minty
import SwiftUI

struct TagDetail: View {
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var data: DataSource

    @ObservedObject var tag: TagViewModel

    @StateObject private var recentPosts: PostQueryViewModel
    @StateObject private var search: PostQueryViewModel
    @StateObject private var newPosts = NewPostListViewModel()

    @State private var showingEditor = false

    @ViewBuilder
    private var addButton: some View {
        NewPostButton(tag: tag.preview)
    }

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
        PaddedScrollView {
            tagInfo
            controls

            recentlyAdded
            posts
        }
        .navigationTitle(tag.name)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingEditor) { TagEditor(tag: tag) }
        .toolbar {
            Button("Edit") {
                showingEditor.toggle()
            }
        }
        .loadEntity(tag)
        .prepareSearch(recentPosts)
        .prepareSearch(search)
        .onAppear {
            if tag.deleted { dismiss() }
            newPosts.data = data
        }
        .onReceive(tag.$deleted) { if $0 { dismiss() } }
    }

    @ViewBuilder
    private var controls: some View {
        HStack {
            Spacer()
            searchButton
            Spacer()
            addButton
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
    private var posts: some View {
        if tag.postCount > 0 {
            if newPosts.posts.isEmpty {
                Divider()
            }
            else {
                HStack {
                    Text("Tagged Posts")
                        .bold()
                        .font(.title2)
                        .padding([.horizontal, .top])
                    Spacer()
                }
            }

            PostSearchResults(search: recentPosts, showResultCount: false)
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
    private var recentlyAdded: some View {
        NewPostList(newPosts: newPosts)
    }

    @ViewBuilder
    private var searchButton: some View {
        NavigationLink(destination: PostSearch(search: search)) {
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
            aliases
            description
            metadata
        }
        .padding()
    }

    init(tag: TagViewModel, preview: TagPreview) {
        self.tag = tag
        _recentPosts = StateObject(wrappedValue: PostQueryViewModel(
            tag: preview,
            searchNow: true
        ))
        _search = StateObject(wrappedValue: PostQueryViewModel(tag: preview))
    }
}

struct TagDetailContainer: View {
    @EnvironmentObject var data: DataSource

    let tag: TagPreview

    var body: some View {
        TagDetail(tag: data.tag(id: tag.id), preview: tag)
    }
}

struct TagDetail_Previews: PreviewProvider {
    private static let tag = TagPreview.preview(id: "1")

    static var previews: some View {
        NavigationView {
            TagDetailContainer(tag: tag)
        }
        .withErrorHandling()
        .environmentObject(DataSource.preview)
        .environmentObject(ObjectSource.preview)
    }
}

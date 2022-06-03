import Minty
import SwiftUI

struct TagDetail: View {
    @Environment(\.dismiss) var dismiss

    @ObservedObject var tag: TagViewModel

    @StateObject private var recentPosts: PostQueryViewModel
    @StateObject private var search: PostQueryViewModel

    @State private var showingEditor = false

    var body: some View {
        PaddedScrollView {
            tagInfo
            controls

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
        }
        .onReceive(tag.$deleted) { if $0 { dismiss() } }
    }

    @ViewBuilder
    private var addButton: some View {
        NewPostButton(tag: tag) {
            // Refresh the recent posts list to make sure the new post
            // appears here if it's tagged with this tag.
            // Refresh after a short delay to avoid a race condition in which
            // the new post does not appear in the results.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                Task {
                    try? await recentPosts.refresh()
                }
            }
        }
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
        if recentPosts.total > 0 {
            Divider()
            PostSearchResults(search: recentPosts, showResultCount: false)
        }
    }

    @ViewBuilder
    private var postCount: some View {
        Label(
            "\(recentPosts.total) Post\(recentPosts.total == 1 ? "" : "s")",
            systemImage: "doc.text.image"
        )
        .font(.caption)
        .foregroundColor(.secondary)
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

    init(tag: TagViewModel) {
        self.tag = tag
        _recentPosts = StateObject(wrappedValue: PostQueryViewModel(
            tag: tag,
            searchNow: true
        ))
        _search = StateObject(wrappedValue: PostQueryViewModel(tag: tag))
    }
}

struct TagDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TagDetail(tag: TagViewModel.preview(id: PreviewTag.helloWorld))
        }
        .withErrorHandling()
        .environmentObject(DataSource.preview)
        .environmentObject(ObjectSource.preview)
    }
}

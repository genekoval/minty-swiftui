import Minty
import SwiftUI

struct TagDetail: View {
    @EnvironmentObject private var errorHandler: ErrorHandler

    @ObservedObject var tag: TagViewModel

    @ObservedObject var recentPosts: PostQueryViewModel
    @ObservedObject var search: PostQueryViewModel

    var body: some View {
        PaddedScrollView {
            tagInfo
            controls
            posts
        }
        .refreshable {
            do {
                try await tag.refresh()
            }
            catch {
                errorHandler.handle(error: error)
            }

            await recentPosts.newSearch()
        }
    }

    @ViewBuilder
    private var addButton: some View {
        NewPostButton(tag: tag) { draft in tag.draftPost = draft }
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
            ShareLink(item: tag.id.uuidString)
                .labelStyle(.iconOnly)
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
    private var posts: some View {
        PostSearchResults(search: recentPosts, showResultCount: false)
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
            sources
            created
            postCount
        }
        .padding()
    }
}

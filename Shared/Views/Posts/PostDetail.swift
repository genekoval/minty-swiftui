import os
import Minty
import SwiftUI

struct PostDetail: View {
    @EnvironmentObject private var data: DataSource
    @EnvironmentObject private var errorHandler: ErrorHandler

    @ObservedObject var post: PostViewModel

    @State private var comments: [Comment] = []
    @State private var error: String?
    @State private var task: Task<Void, Never>?
    @State private var showProgress = false

    var body: some View {
        PaddedScrollView {
            postInfo
            controls

            ProgressView()
                .opacity(showProgress ? 1 : 0)

            if let error {
                NoResults(
                    heading: "Failed to fetch comments",
                    subheading: error
                )
            }
            else {
                commentList
            }
        }
        .onAppear {
            if comments.count != post.commentCount {
                fetchComments()
            }
        }
        .onDisappear { task?.cancel() }
        .refreshable {
            do {
                try await post.refresh()
                fetchComments()
            }
            catch {
                errorHandler.handle(error: error)
            }
        }
    }

    @ViewBuilder
    private var commentList: some View {
        VStack(spacing: 0) {
            ForEach(comments) { comment in
                CommentRow(comment: comment, post: post) { reply in
                    guard let index = comments.firstIndex(of: comment) else {
                        Logger.ui.fault(
                            "Missing parent comment \(comment.id)"
                        )

                        errorHandler.handle(error: MintyError.unspecified(
                            message: "The parent comment does not exist."
                        ))

                        return
                    }

                    withAnimation {
                        comments.insert(reply, at: index + 1)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var commentCount: some View {
        if post.commentCount > 0 {
            Label(
                post.commentCount.asCountOf("Comment"),
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
            NewCommentButton(post: post) { comment in
                withAnimation {
                    comments.insert(comment, at: 0)
                }
            }
            Spacer()
            ShareLink(item: post.id.uuidString)
                .labelStyle(.iconOnly)
            Spacer()
        }
        .padding(.vertical, 5)
    }

    @ViewBuilder
    private var created: some View {
        Timestamp(
            prefix: post.visibility == .draft ? "Created" : "Posted",
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
                        destination: PostHost(post: post)
                    ) {
                        PostRowMinimal(post: post)
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
            NavigationLink(destination: PostTagList(post: post)) {
                Label(post.tags.countOf(type: "Tag"), systemImage: "tag")
                    .font(.caption)
            }
        }
        else if let tag = post.tags.first {
            NavigationLink(destination: TagHost(tag: tag)) {
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

    private func fetchComments() {
        guard post.commentCount > 0 else {
            comments.removeAll()
            return
        }

        guard let repo = data.repo else {
            error = "Missing repo"
            return
        }

        task?.cancel()

        task = Task {
            Logger.ui.debug("Fetching comments for post \(post.id)")

            let progress = Task.after(.milliseconds(100)) {
                withAnimation { showProgress = true }
            }

            defer {
                progress.cancel()
                task = nil
            }

            do {
                let comments = try await repo.getComments(for: post.id)

                withAnimation {
                    error = nil
                    showProgress = false
                    self.comments = comments
                }
            }
            catch {
                if Task.isCancelled {
                    Logger.ui.debug("Fetching comments cancelled")
                }
                else {
                    showProgress = false

                    if comments.isEmpty {
                        self.error = error.localizedDescription
                    }
                }
            }
        }
    }
}

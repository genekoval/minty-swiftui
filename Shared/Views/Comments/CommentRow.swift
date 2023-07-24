import Minty
import SwiftUI

private let indentSpacing: CGFloat = 15

private struct IndentSpacer: View {
    var body: some View {
        HStack {
            Divider()
        }
        .padding([.leading], indentSpacing)
    }
}

private struct Indent: View {
    let spaces: Int

    var body: some View {
        ForEach(0..<spaces, id: \.self) { _ in IndentSpacer() }
    }
}

struct CommentRow: View {
    @StateObject private var comment: CommentViewModel

    var body: some View {
        HStack {
            indent
            commentInfo
        }
    }

    @ViewBuilder
    private var commentInfo: some View {
        VStack(alignment: .leading) {
            Divider()

            header
            content
        }
        .padding(5)
    }

    @ViewBuilder
    private var content: some View {
        Text(comment.content)
            .font(.callout)
            .textSelection(.enabled)
    }

    @ViewBuilder
    private var created: some View {
        Label(comment.created.relative(.short), systemImage: "clock")
            .font(.caption)
            .foregroundColor(.secondary)
    }

    @ViewBuilder
    private var header: some View {
        HStack {
            Spacer()

            created
            menu
        }
        .padding([.top, .bottom], 1)
    }

    @ViewBuilder
    private var indent: some View {
        Indent(spaces: comment.indent)
    }

    @ViewBuilder
    private var menu: some View {
        CommentMenu(comment: comment)
    }

    init(comment: Comment, post: PostViewModel) {
        _comment = StateObject(wrappedValue: CommentViewModel(
            comment: comment,
            post: post
        ))
    }
}

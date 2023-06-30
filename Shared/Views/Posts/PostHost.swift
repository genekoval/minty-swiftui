import SwiftUI

struct PostHost: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var data: DataSource
    @EnvironmentObject private var errorHandler: ErrorHandler

    @ObservedObject var post: PostViewModel

    var body: some View {
        content
            .loadEntity(post)
            .navigationTitle(post.visibility == .draft ? "Draft" : "Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { edit }
            .onAppear { if post.deleted { dismiss() }}
            .onReceive(post.$deleted) { if $0 { dismiss() }}
    }

    @ViewBuilder
    private var content: some View {
        if post.isEditing {
            PostEditor(post: post)
        }
        else {
            PostDetail(post: post)
        }
    }

    @ViewBuilder
    private var edit: some View {
        Button(action: {
            post.isEditing.toggle()
        }) {
            if post.isEditing {
                Text(post.visibility == .draft ? "Preview" : "Done")
                    .bold()
            }
            else {
                Text("Edit")
            }
        }
    }
}

/*
struct PostHost_Previews: PreviewProvider {
    private static let tag = TagViewModel.preview(id: PreviewTag.empty)

    static var previews: some View {
        NavigationView {
            PostHost(post: $tag.draftPost)
        }
        .withErrorHandling()
        .environmentObject(DataSource.preview)
        .environmentObject(ObjectSource.preview)
        .environmentObject(Overlay())
    }
}
*/

import SwiftUI

struct PostMenu: View {
    @ObservedObject var post: PostViewModel

    @State private var showingEditor = false

    var body: some View {
        Menu {
            edit
            copy
        }
        label: {
            Image(systemName: "ellipsis.circle")
        }
        .sheet(isPresented: $showingEditor) { PostEditor(post: post) }
    }

    @ViewBuilder
    private var copy: some View {
        CopyID(entity: post)
    }

    @ViewBuilder
    private var edit: some View {
        Button(action: { showingEditor = true }) {
            Label("Edit", systemImage: "pencil")
        }
    }
}

struct PostMenu_Previews: PreviewProvider {
    static var previews: some View {
        PostMenu(post: PostViewModel.preview(id: PreviewPost.sandDune))
    }
}

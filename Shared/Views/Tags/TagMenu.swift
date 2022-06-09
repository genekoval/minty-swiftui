import SwiftUI

struct TagMenu: View {
    @ObservedObject var tag: TagViewModel

    @State private var showingEditor = false

    var body: some View {
        Menu {
            edit
            copy
        }
        label: {
            Image(systemName: "ellipsis.circle")
        }
        .sheet(isPresented: $showingEditor) { TagEditor(tag: tag) }
    }

    @ViewBuilder
    private var copy: some View {
        CopyID(entity: tag)
    }

    @ViewBuilder
    private var edit: some View {
        Button(action: { showingEditor = true }) {
            Label("Edit", systemImage: "pencil")
        }
    }
}

struct TagMenu_Previews: PreviewProvider {
    static var previews: some View {
        TagMenu(tag: TagViewModel.preview(id: PreviewTag.helloWorld))
    }
}

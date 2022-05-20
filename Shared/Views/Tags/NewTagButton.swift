import Minty
import SwiftUI

private struct TagDetailLink: View {
    @EnvironmentObject var data: DataSource

    let id: Tag.ID?

    @Binding var isActive: Bool

    var body: some View {
        if let id = id {
            NavigationLink(
                destination: TagDetail(tag: data.state.tags.fetch(id: id)),
                isActive: $isActive
            ) {
                EmptyView()
            }
        }
    }
}

struct NewTagButton: View {
    @State private var newTagId: Tag.ID?
    @State private var showingNewTag = false
    @State private var showingEditor = false

    var body: some View {
        Button(action: { showingEditor = true }) {
            Image(systemName: "plus")
        }
        .background(
            TagDetailLink(id: newTagId, isActive: $showingNewTag)
        )
        .sheet(isPresented: $showingEditor) {
            NewTag(onCreated: onNewTag)
        }
    }

    private func onNewTag(id: Tag.ID) {
        newTagId = id
        showingNewTag = true
    }
}

struct NewTagButton_Previews: PreviewProvider {
    static var previews: some View {
        NewTagButton()
    }
}

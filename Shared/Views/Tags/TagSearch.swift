import Minty
import SwiftUI

struct TagSearch: View {
    @EnvironmentObject var data: DataSource
    @StateObject private var query = TagQueryViewModel()

    @State private var addingTag = false
    @State private var newTagId: String?
    @State private var newTagName = ""
    @State private var selection: String?

    var body: some View {
        TagHome(query: query, selection: $selection)
            .buttonStyle(PlainButtonStyle())
            .navigationTitle("Tags")
            .onAppear { query.repo = data.repo }
            .searchable(text: $query.name)
            .sheet(isPresented: $addingTag, onDismiss: newTagDismissed) {
                NewTag(id: $newTagId, name: $newTagName)
            }
            .toolbar {
                Button(action: { addingTag.toggle() }) {
                    Image(systemName: "plus")
                        .accessibilityLabel("Add Tag")
                }
            }
    }

    private func newTagDismissed() {
        guard let id = newTagId else { return }

        var tag = TagPreview()
        tag.id = id
        tag.name = newTagName

        query.excluded.append(tag)

        newTagId = nil
        newTagName = ""

        selection = id
    }
}

struct TagSearch_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TagSearch()
                .environmentObject(DataSource.preview)
                .environmentObject(ObjectSource.preview)
        }
    }
}

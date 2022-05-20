import Minty
import SwiftUI

struct TagSearch: View {
    @StateObject private var query = TagQueryViewModel()

    @State private var addingTag = false
    @State private var newTagId: UUID?
    @State private var newTagName = ""
    @State private var selection: UUID?

    var body: some View {
        TagHome(query: query, selection: $selection)
            .buttonStyle(PlainButtonStyle())
            .navigationTitle("Tags")
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
            .prepareSearch(query)
    }

    private func newTagDismissed() {
        guard let id = newTagId else { return }

        newTagId = nil
        newTagName = ""

        selection = id
    }
}

struct TagSearch_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TagSearch()
                .withErrorHandling()
                .environmentObject(DataSource.preview)
                .environmentObject(ObjectSource.preview)
        }
    }
}

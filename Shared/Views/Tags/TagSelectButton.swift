import Minty
import SwiftUI

struct TagSelectButton: View {
    @Binding var tags: [TagPreview]

    @StateObject private var search: TagQueryViewModel
    @State private var selectorPresented = false

    var body: some View {
        Button(action: { selectorPresented.toggle() }) {
            Label("\(tags.count)", systemImage: "tag")
                .foregroundColor(.accentColor)
        }
        .onAppear {
            search.excluded = tags
        }
        .sheet(isPresented: $selectorPresented) {
            TagSelector(tags: $tags, search: search)
        }
    }

    init(tags: Binding<[TagPreview]>, repo: MintyRepo?) {
        _tags = tags
        _search = StateObject(wrappedValue: TagQueryViewModel(repo: repo))
    }
}

struct TagSelectButton_Previews: PreviewProvider {
    private struct Preview: View {
        @State private var tags: [TagPreview] = []

        var body: some View {
            TagSelectButton(tags: $tags, repo: PreviewRepo())
        }
    }

    static var previews: some View {
        Preview()
    }
}

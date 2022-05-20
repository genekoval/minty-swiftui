import Minty
import SwiftUI

struct TagSelectButton: View {
    @Binding var tags: [TagViewModel]

    @StateObject private var search = TagQueryViewModel()
    @State private var selectorPresented = false

    var body: some View {
        Button(action: { selectorPresented.toggle() }) {
            Label("\(tags.count)", systemImage: "tag")
                .foregroundColor(.accentColor)
        }
        .prepareSearch(search)
        .onAppear {
            search.excluded = tags
        }
        .sheet(isPresented: $selectorPresented) {
            NavigationView {
                TagSelector(tags: $tags, search: search)
            }
        }
    }
}

struct TagSelectButton_Previews: PreviewProvider {
    private struct Preview: View {
        @State private var tags: [TagViewModel] = []

        var body: some View {
            TagSelectButton(tags: $tags)
        }
    }

    static var previews: some View {
        Preview()
    }
}

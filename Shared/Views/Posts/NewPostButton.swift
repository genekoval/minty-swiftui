import Minty
import SwiftUI

struct NewPostButton: View {
    @EnvironmentObject var data: DataSource

    let tag: TagPreview?

    @State private var showingEditor = false

    var body: some View {
        Button(action: { showingEditor = true }) {
            Image(systemName: "plus")
        }
        .sheet(isPresented: $showingEditor) {
            NewPostView(tag: tag)
        }
    }

    init(tag: TagPreview? = nil) {
        self.tag = tag
    }
}

struct NewPostButton_Previews: PreviewProvider {
    static var previews: some View {
        NewPostButton()
            .environmentObject(DataSource.preview)
    }
}

import Combine
import Minty
import SwiftUI

struct NewPostButton: View {
    @EnvironmentObject var data: DataSource

    let newPost: PassthroughSubject<String, Never>
    let tag: TagPreview?

    @State private var showingEditor = false

    var body: some View {
        Button(action: { showingEditor = true }) {
            Image(systemName: "plus")
        }
        .sheet(isPresented: $showingEditor) {
            NewPostView(repo: data.repo, newPost: newPost, tag: tag)
        }
    }

    init(newPost: PassthroughSubject<String, Never>, tag: TagPreview? = nil) {
        self.newPost = newPost
        self.tag = tag
    }
}

struct NewPostButton_Previews: PreviewProvider {
    private static let newPost = PassthroughSubject<String, Never>()

    static var previews: some View {
        NewPostButton(newPost: PassthroughSubject<String, Never>())
            .environmentObject(DataSource.preview)
    }
}

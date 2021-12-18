import SwiftUI

struct NewPostButton: View {
    @EnvironmentObject var data: DataSource

    let onCreate: (String) -> Void

    @State private var showingEditor = false

    var body: some View {
        Button(action: { showingEditor = true }) {
            Image(systemName: "plus")
        }
        .sheet(isPresented: $showingEditor) {
            NewPostView(repo: data.repo, onCreate: onCreate)
        }
    }
}

struct NewPostButton_Previews: PreviewProvider {
    static var previews: some View {
        NewPostButton(onCreate: { _ in })
            .environmentObject(DataSource.preview)
    }
}

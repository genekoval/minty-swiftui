import SwiftUI

struct PostEditor: View {
    @Environment(\.dismiss) var dismiss

    @ObservedObject var post: PostViewModel

    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Button("Delete Post", role: .destructive) {
                        showingDeleteAlert.toggle()
                    }
                }
            }
            .alert(
                Text("Delete this post?"),
                isPresented: $showingDeleteAlert
            ) {
                Button("Delete", role: .destructive) { delete() }
            } message: { Text("This action cannot be undone.") }
            .navigationTitle("Edit Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(action: { dismiss() }) {
                    Text("Done")
                        .bold()
                }
            }
        }
    }

    private func delete() {
        post.delete()
        dismiss()
    }
}

struct PostEditor_Previews: PreviewProvider {
    private static let deleted = Deleted()
    private static let post = PostViewModel.preview(
        id: "test",
        deleted: deleted
    )

    static var previews: some View {
        PostEditor(post: post)
    }
}

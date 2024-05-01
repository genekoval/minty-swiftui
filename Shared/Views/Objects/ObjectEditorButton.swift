import SwiftUI

struct ObjectEditorButton: View {
    @Environment(\.postControlsHidden) private var postControlsHidden

    @ObservedObject var post: PostViewModel

    @State private var isPresented = false

    var body: some View {
        if post.objects.isEmpty {
            SecondaryButton(action: { isPresented = true }) {
                Label("Attach Files", systemImage: "photo")
            }
            .objectUploadView(isPresented: $isPresented) {
                try await post.add(objects: $0)
            }
            .onAppear {
                postControlsHidden.wrappedValue = false
            }
        }
        else {
            ObjectEditorGrid(post: post)
        }
    }
}

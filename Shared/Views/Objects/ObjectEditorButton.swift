import SwiftUI

struct ObjectEditorButton: View {
    @ObservedObject var post: PostViewModel

    @State private var isPresented = false

    var body: some View {
        Button(action: { isPresented = true }) {
            Label("Objects", systemImage: "doc")
        }
        .badge(post.objects.count)
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                if post.objects.isEmpty {
                    ObjectUploadView {
                        try await post.add(objects: $0)
                    }
                }
                else {
                    ObjectEditorGrid(post: post)
                }
            }
        }
    }
}

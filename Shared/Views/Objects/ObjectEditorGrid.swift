import Minty
import SwiftUI

private enum EditorItem: Identifiable {
    case object(ObjectPreview)
    case addButton

    var id: String {
        switch self {
        case .object(let object):
            return object.id
        case .addButton:
            return "button.add"
        }
    }
}

struct ObjectEditorGrid: View {
    @ObservedObject var post: PostViewModel

    @State private var items: [EditorItem] = []
    @State private var insertionPoint: Int = -1

    var body: some View {
        ScrollView {
            VStack {
                Grid {
                    ForEach(items) { itemView($0) }
                }
            }
        }
        .navigationTitle("Objects")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(post.$objects) { rebuildItems(objects: $0) }
    }

    private func didUpload(objects: [String]) {
        post.addObjects(objects, at: insertionPoint)
    }

    private func rebuildItems(objects: [ObjectPreview]) {
        if insertionPoint < 0 {
            insertionPoint = objects.count
        }

        items.removeAll(keepingCapacity: true)

        for object in objects {
            items.append(.object(object))
        }

        items.append(.addButton)
    }

    @ViewBuilder
    private func itemView(_ item: EditorItem) -> some View {
        switch item {
        case .object(let object):
            PreviewImage(object: object)
        case .addButton:
            ObjectUploadButton(onUpload: { didUpload(objects: $0) })
                .frame(width: 50)
        }
    }
}

struct ObjectEditorGrid_Previews: PreviewProvider {
    private static let deleted = Deleted()
    @State private static var post = PostViewModel.preview(
        id: "test",
        deleted: deleted
    )

    static var previews: some View {
        NavigationView {
            ObjectEditorGrid(post: post)
        }
        .environmentObject(ObjectSource.preview)
    }
}

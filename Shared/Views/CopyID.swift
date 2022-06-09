import SwiftUI

struct CopyID<Entity>: View where Entity : Identifiable, Entity.ID == UUID {
    let entity: Entity

    var body: some View {
        Button(action: copyId) {
            Label("Copy ID", systemImage: "doc.on.doc")
        }
    }

    private func copyId() {
        UIPasteboard.general.string = entity.id.uuidString
    }
}

struct CopyID_Previews: PreviewProvider {
    static var previews: some View {
        CopyID(entity: TagViewModel.preview(id: PreviewTag.helloWorld))
    }
}

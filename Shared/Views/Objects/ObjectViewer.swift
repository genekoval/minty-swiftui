import Minty
import SwiftUI

struct ObjectViewer: View {
    let object: ObjectPreview

    var body: some View {
        switch (object.type) {
        case "image":
            ImageViewer(object: object)
        default:
            EmptyView()
        }
    }
}

struct ObjectViewer_Previews: PreviewProvider {
    static var previews: some View {
        ObjectViewer(object: ObjectPreview.preview(id: "sand dune.jpg"))
            .environmentObject(ObjectSource.preview)
            .environmentObject(Overlay())
            .environmentObject(MediaPlayer.preview)
    }
}

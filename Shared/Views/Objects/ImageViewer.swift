import Minty
import SwiftUI

struct ImageViewer: View {
    let object: ObjectPreview

    var body: some View {
        switch object.subtype {
        case "gif":
            GifViewer(object: object)
        default:
            DefaultImageViewer(object: object)
        }
    }
}

struct ImageViewer_Previews: PreviewProvider {
    static var previews: some View {
        ImageViewer(object: ObjectPreview.preview(id: PreviewObject.sandDune))
            .environmentObject(ObjectSource.preview)
            .environmentObject(Overlay())
    }
}

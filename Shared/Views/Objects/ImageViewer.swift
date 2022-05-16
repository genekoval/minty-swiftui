import Combine
import Minty
import SwiftUI

struct ImageViewer: View {
    let object: ObjectPreview

    @State private var scale: CGFloat = 1

    var body: some View {
        ImageObject(id: object.id)
            .swipeToDismiss(active: scale == 1)
            .scaledToFit()
            .zoomable(scale: $scale, minScale: 1)
            .tapToHide()
    }
}

struct ImageViewer_Previews: PreviewProvider {
    static var previews: some View {
        ImageViewer(object: ObjectPreview.preview(id: PreviewObject.sandDune))
            .environmentObject(ObjectSource.preview)
            .environmentObject(Overlay())
    }
}

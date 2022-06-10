import Minty
import SwiftUI

struct DefaultImageViewer: View {
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

struct DefaultImageViewer_Previews: PreviewProvider {
    static var previews: some View {
        DefaultImageViewer(
            object: ObjectPreview.preview(id: PreviewObject.sandDune)
        )
        .environmentObject(ObjectSource.preview)
        .environmentObject(Overlay())
    }
}

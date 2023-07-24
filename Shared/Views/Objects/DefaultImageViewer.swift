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

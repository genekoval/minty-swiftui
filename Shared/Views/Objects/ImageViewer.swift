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

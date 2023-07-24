import Minty
import SwiftUI

struct ObjectViewer: View {
    let object: ObjectPreview

    var body: some View {
        switch object.type {
        case "image":
            ImageViewer(object: object)
        default:
            EmptyView()
        }
    }
}

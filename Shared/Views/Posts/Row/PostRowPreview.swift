import Minty
import SwiftUI

struct PostRowPreview: View {
    let object: ObjectPreview?

    var body: some View {
        if let object = object {
            PreviewImage(object: object)
        }
        else {
            Image(systemName: "text.justifyleft")
                .font(.title)
                .foregroundColor(.secondary)
        }
    }
}

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

struct PostRowPreview_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PostRowPreview(object: ObjectPreview.preview(id: "sand dune.jpg"))

            PostRowPreview(object: ObjectPreview.preview(id: "empty"))

            PostRowPreview(object: nil)
        }
        .withErrorHandling()
        .environmentObject(ObjectSource.preview)
    }
}

import Minty
import SwiftUI

struct ObjectGrid: View {
    let objects: [ObjectPreview]

    var body: some View {
        Grid {
            ForEach(objects) { object in
                PreviewImage(object: object)
            }
        }
    }
}

struct ObjectGrid_Previews: PreviewProvider {
    private static let objects = [
        "sand dune.jpg",
        "empty"
    ]

    static var previews: some View {
        Group {
            ObjectGrid(objects: objects.map { ObjectPreview.preview(id: $0) })
                .environmentObject(ObjectSource.preview)
        }
    }
}

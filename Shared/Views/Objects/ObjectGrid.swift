import Minty
import SwiftUI

struct ObjectGrid: View {
    @EnvironmentObject var data: DataSource

    let objects: [ObjectPreview]

    var body: some View {
        Grid {
            ForEach(objects) { object in
                NavigationLink(destination: ObjectDetail(
                    id: object.id,
                    repo: data.repo
                )) {
                    PreviewImage(object: object)
                }
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
                .environmentObject(DataSource.preview)
                .environmentObject(ObjectSource.preview)
        }
    }
}

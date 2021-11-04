import Minty
import SwiftUI

// The spacing between individual items in the grid.
private let spacing: CGFloat = 2

private struct NoPreview: View {
    let type: String

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: "doc")
                .font(.title)
            Text(type)
                .font(.caption)
        }
        .foregroundColor(.secondary)
    }
}

@MainActor
struct ObjectGrid: View {
    let objects: [ObjectPreview]

    private var columns: [GridItem] = Array(
        repeating: .init(.flexible(), spacing: spacing),
        count: 3
    )

    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(objects) { object in
                ImageObject(id: object.previewId) {
                    NoPreview(type: object.mimeType)
                }
                .aspectRatio(contentMode: .fit)
            }
        }
    }

    init(objects: [ObjectPreview]) {
        self.objects = objects
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

            NoPreview(type: "text/plain")
        }
    }
}

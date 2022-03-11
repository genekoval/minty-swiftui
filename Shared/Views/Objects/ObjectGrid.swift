import Minty
import SwiftUI

private struct ObjectDetailLink<Content>: View where Content : View {
    @EnvironmentObject var data: DataSource

    let id: String

    @Binding var selection: String?

    @ViewBuilder let content: () -> Content

    var body: some View {
        NavigationLink(
            destination: ObjectDetail(id: id, repo: data.repo),
            tag: id,
            selection: $selection
        ) {
            content()
        }
    }
}

private struct ObjectGridItem: View {
    @EnvironmentObject var overlay: Overlay
    @EnvironmentObject var player: MediaPlayer

    let object: ObjectPreview

    @Binding var selection: String?

    var body: some View {
        if object.isMedia || object.isViewable {
            Button(action: viewObject) {
                preview
            }
            .background {
                ObjectDetailLink(id: object.id, selection: $selection) {
                    EmptyView()
                }
            }
        }
        else {
            ObjectDetailLink(id: object.id, selection: $selection) { preview }
        }
    }

    @ViewBuilder
    private var infoButton: some View {
        Button(action: { selection = object.id }) {
            Label("Get Info", systemImage: "info.circle")
        }
    }

    @ViewBuilder
    private var preview: some View {
        PreviewImage(object: object)
            .contextMenu {
                infoButton
            }
    }

    private func viewObject() {
        if object.isMedia {
            player.currentItem = object
            player.maximize()
        }
        else if object.isViewable {
            overlay.show(object: object)
        }
    }
}

struct ObjectGrid: View {
    @EnvironmentObject var overlay: Overlay

    let objects: [ObjectPreview]

    @State private var selection: String?

    var body: some View {
        Grid {
            ForEach(objects) {
                ObjectGridItem(object: $0, selection: $selection)
            }
        }
        .onAppear { prepareOverlay() }
    }

    private func prepareOverlay() {
        overlay.load(
            objects: objects.filter { $0.isViewable },
            infoPresented: $selection
        )
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
                .environmentObject(Overlay())
                .environmentObject(MediaPlayer.preview)
        }
    }
}

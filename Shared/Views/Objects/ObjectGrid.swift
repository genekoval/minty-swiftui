import Minty
import SwiftUI

private struct PreviewItem: View {
    let object: ObjectPreview

    @Binding var detail: UUID?

    var body: some View {
        PreviewImage(object: object)
            .contextMenu {
                copy
                info
                share
            }
    }

    @ViewBuilder
    private var copy: some View {
        CopyID(entity: object)
    }

    @ViewBuilder
    private var info: some View {
        Button(action: { detail = object.id }) {
            Label("Get Info", systemImage: "info.circle")
        }
    }

    @ViewBuilder
    private var share: some View {
        ObjectShareLink(object: object)
    }
}

private struct ViewableItem: View {
    @EnvironmentObject private var overlay: Overlay

    let object: ObjectPreview

    @Binding var detail: UUID?

    var body: some View {
        Button(action: viewObject) {
            PreviewItem(object: object, detail: $detail)
        }
    }

    private func viewObject() {
        overlay.show(object: object)
    }
}

private struct MediaItem: View {
    @EnvironmentObject private var player: MediaPlayer

    let object: ObjectPreview

    @Binding var detail: UUID?

    var body: some View {
        Button(action: viewObject) {
            PreviewItem(object: object, detail: $detail)
        }
    }

    private func viewObject() {
        player.currentItem = object
        player.maximize()
    }
}

private struct PlainItem: View {
    let object: ObjectPreview

    @Binding var detail: UUID?

    var body: some View {
        NavigationLink(destination: ObjectDetail(id: object.id)) {
            PreviewItem(object: object, detail: $detail)
        }
    }
}

struct ObjectGrid: View {
    @EnvironmentObject var overlay: Overlay

    let provider: ObjectProvider

    @State private var detail: UUID?

    var body: some View {
        Grid {
            ForEach(provider.objects) { object in
                if object.isMedia {
                    MediaItem(object: object, detail: $detail)
                }
                else if object.isViewable {
                    ViewableItem(object: object, detail: $detail)
                }
                else {
                    PlainItem(object: object, detail: $detail)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationDestination(item: $detail) { id in
            ObjectDetail(id: id)
        }
        .onAppear {
            overlay.load(provider: provider)
        }
    }
}

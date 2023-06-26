import Minty
import SwiftUI

private struct PreviewItem: View {
    let object: ObjectPreview

    @State private var infoPresented = false

    var body: some View {
        PreviewImage(object: object)
            .contextMenu {
                copy
                info
                share
            }
            .navigationDestination(isPresented: $infoPresented) {
                ObjectDetail(id: object.id)
            }
    }

    @ViewBuilder
    private var copy: some View {
        CopyID(entity: object)
    }

    @ViewBuilder
    private var info: some View {
        Button(action: { infoPresented = true }) {
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

    var body: some View {
        Button(action: viewObject) { PreviewItem(object: object) }
    }

    private func viewObject() {
        overlay.show(object: object)
    }
}

private struct MediaItem: View {
    @EnvironmentObject private var player: MediaPlayer

    let object: ObjectPreview

    var body: some View {
        Button(action: viewObject) { PreviewItem(object: object) }
    }

    private func viewObject() {
        player.currentItem = object
        player.maximize()
    }
}

private struct PlainItem: View {
    let object: ObjectPreview

    var body: some View {
        NavigationLink(destination: ObjectDetail(id: object.id)) {
            PreviewItem(object: object)
        }
    }
}

struct ObjectGrid: View {
    @EnvironmentObject var overlay: Overlay

    let provider: ObjectProvider

    var body: some View {
        Grid {
            ForEach(provider.objects) { object in
                if object.isMedia { MediaItem(object: object) }
                else if object.isViewable { ViewableItem(object: object) }
                else { PlainItem(object: object) }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            overlay.load(provider: provider)
        }
    }
}

struct ObjectGrid_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ObjectGrid(provider: PostViewModel.preview(id: PreviewPost.test))
                .environmentObject(DataSource.preview)
                .environmentObject(ObjectSource.preview)
                .environmentObject(Overlay())
                .environmentObject(MediaPlayer.preview)
        }
    }
}

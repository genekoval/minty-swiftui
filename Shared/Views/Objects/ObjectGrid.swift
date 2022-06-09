import Minty
import SwiftUI

private struct ObjectDetailLink<Content>: View where Content : View {
    @EnvironmentObject var data: DataSource

    let id: UUID

    @Binding var selection: UUID?

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
    let provider: ObjectProvider

    @Binding var selection: UUID?

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
    private var copyButton: some View {
        CopyID(entity: object)
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
                copyButton
            }
    }

    private func viewObject() {
        if object.isMedia {
            player.currentItem = object
            player.maximize()
        }
        else if object.isViewable {
            overlay.load(provider: provider, infoPresented: $selection)
            overlay.show(object: object)
        }
    }
}

struct ObjectGrid: View {
    @EnvironmentObject var overlay: Overlay

    let provider: ObjectProvider

    @State private var selection: UUID?

    var body: some View {
        Grid {
            ForEach(provider.objects) {
                ObjectGridItem(
                    object: $0,
                    provider: provider,
                    selection: $selection
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            overlay.load(provider: provider, infoPresented: $selection)
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

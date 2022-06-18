import Gifu
import Minty
import SwiftUI

private struct GIFView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> GIFImageView {
        let view = GIFImageView()

        view.contentMode = .scaleAspectFit
        view.setShouldResizeFrames(true)
        view.animate(withGIFURL: url)

        return view
    }

    func updateUIView(_ uiView: GIFImageView, context: Context) { }
}

struct GifViewer: View {
    @EnvironmentObject var errorHandler: ErrorHandler
    @EnvironmentObject var objects: ObjectSource

    let object: ObjectPreview

    @State private var url: URL?

    var body: some View {
        if let url = url {
            GIFView(url: url)
                .swipeToDismiss()
                .scaledToFit()
                .tapToHide()
        }
        else {
            ProgressView().task { await load() }
        }
    }

    private func load() async {
        do {
            url = try await objects.url(for: object.id)
        }
        catch {
            errorHandler.handle(error: error)
        }
    }
}

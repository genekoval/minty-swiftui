import Minty
import SwiftUI

struct OverlayView: View {
    @Environment(\.colorScheme) var colorScheme

    @EnvironmentObject var overlay: Overlay

    var body: some View {
        ZStack {
            background
                .ignoresSafeArea()
                .opacity(overlay.opacity)

            ObjectReel()
                .ignoresSafeArea()

            if overlay.uiVisible {
                OverlayNavigationBar()
                    .opacity(overlay.opacity)
            }
        }
        .statusBar(hidden: !overlay.uiVisible)
        .persistentSystemOverlays(overlay.uiVisible ? .automatic : .hidden)
    }

    @ViewBuilder
    private var background: some View {
        colorScheme == .light && overlay.uiVisible ? Color.white : Color.black
    }
}

struct OverlayView_Previews: PreviewProvider {
    @StateObject private static var overlay: Overlay = {
        let result = Overlay()

        result.load(provider: PostViewModel.preview(id: PreviewPost.test))

        return result
    }()

    static var previews: some View {
        OverlayView()
            .environmentObject(ObjectSource.preview)
            .environmentObject(overlay)
    }
}

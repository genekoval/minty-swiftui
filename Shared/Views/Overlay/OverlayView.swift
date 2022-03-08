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
    }

    @ViewBuilder
    private var background: some View {
        colorScheme == .light && overlay.uiVisible ? Color.white : Color.black
    }
}

struct OverlayView_Previews: PreviewProvider {
    @StateObject private static var overlay: Overlay = {
        let result = Overlay()

        result.load(objects: [ObjectPreview.preview(id: "sand dune.jpg")])

        return result
    }()

    static var previews: some View {
        OverlayView()
            .environmentObject(ObjectSource.preview)
            .environmentObject(overlay)
    }
}
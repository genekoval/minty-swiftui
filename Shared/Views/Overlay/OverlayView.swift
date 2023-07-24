import Minty
import SwiftUI

struct OverlayView: View {
    @Environment(\.colorScheme) private var colorScheme

    @EnvironmentObject private var overlay: Overlay

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

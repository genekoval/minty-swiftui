import SwiftUI

private struct ViewerOverlay: ViewModifier {
    @EnvironmentObject var overlay: Overlay

    func body(content: Content) -> some View {
        content
            .overlay {
                if overlay.visible {
                    OverlayView()
                }
            }
    }
}

extension View {
    func viewerOverlay() -> some View {
        modifier(ViewerOverlay())
    }
}

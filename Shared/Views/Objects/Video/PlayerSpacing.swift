import SwiftUI

private struct PlayerSpacing: ViewModifier {
    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: miniPlayerHeight)
            }
    }
}

extension View {
    func playerSpacing() -> some View {
        modifier(PlayerSpacing())
    }
}

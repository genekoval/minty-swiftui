import SwiftUI

private struct PlayerSpacing: ViewModifier {
    @EnvironmentObject private var player: MediaPlayer

    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: height)
            }
    }

    private var height: CGFloat {
        if player.visible {
            return MiniPlayer.height
        }
        else {
            return 0
        }
    }
}

extension View {
    func playerSpacing() -> some View {
        modifier(PlayerSpacing())
    }
}

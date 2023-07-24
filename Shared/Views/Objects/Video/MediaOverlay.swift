import SwiftUI

struct MediaOverlay: View {
    @EnvironmentObject var player: MediaPlayer

    let frame: CGRect

    var body: some View {
        if player.isMaximized {
            MediaPlayerView()
                .ignoresSafeArea()
                .transition(.move(edge: .bottom))
        }
        else if player.visible {
            miniPlayer
                .transition(.move(edge: .bottom))
        }
    }

    @ViewBuilder
    private var miniPlayer: some View {
        MiniPlayer()
            .onTapGesture {
                player.maximize()
            }
            .position(
                x: frame.width / 2,
                y: frame.height - MiniPlayer.height / 2
            )
    }
}

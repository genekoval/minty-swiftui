import SwiftUI

let miniPlayerHeight: CGFloat = 50

struct MediaOverlay: View {
    @EnvironmentObject var player: MediaPlayer

    let frame: CGRect

    var body: some View {
        MiniPlayer()
            .frame(height: miniPlayerHeight)
            .onTapGesture {
                player.isMaximized = true
            }
            .position(
                x: frame.width / 2,
                y: frame.height - miniPlayerHeight / 2
            )
            .fullScreenCover(isPresented: $player.isMaximized) {
                MediaPlayerView()
            }
    }
}

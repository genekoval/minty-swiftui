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
        else if
            player.visibility == .visible ||
            (player.visibility == .automatic && player.currentItem != nil)
        {
            miniPlayer
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

struct MediaOverlay_Previews: PreviewProvider {
    private struct Preview: View {
        var body: some View {
            GeometryReader { geometry in
                MediaOverlay(frame: geometry.frame(in: .local))
            }
        }
    }

    static var previews: some View {
        Preview()
            .environmentObject(MediaPlayer.preview)
            .environmentObject(ObjectSource.preview)
    }
}

import SwiftUI

struct MiniPlayer: View {
    @EnvironmentObject var player: MediaPlayer

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                playerFrame
                    .shadow(radius: 2)

                Spacer()

                PlayButton(player: player, size: 20)
                    .padding(.trailing)
            }

            Divider()
        }
        .foregroundColor(.white)
        .background {
            Rectangle()
                .fill(.thinMaterial)
        }
    }

    @ViewBuilder
    private var playerFrame: some View {
        CustomVideoPlayer(player: player)
            .scaledToFit()
            .padding(.leading)
    }
}

struct MiniPlayer_Previews: PreviewProvider {
    static var previews: some View {
        MiniPlayer()
            .environmentObject(MediaPlayer.preview)
    }
}

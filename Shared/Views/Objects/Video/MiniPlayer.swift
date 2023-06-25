import SwiftUI

private func albumCoverSpacing(_ geometry: GeometryProxy) -> CGFloat {
    geometry.size.height / 3
}

private func albumCoverSize(_ geometry: GeometryProxy) -> CGFloat {
    geometry.size.height - albumCoverSpacing(geometry)
}

struct MiniPlayer: View {
    static let background: Material = .ultraThin
    static let height: CGFloat = 70

    @EnvironmentObject var player: MediaPlayer

    @ViewBuilder
    private var albumCover: some View {
        if player.currentItem == nil || player.currentItem?.type == "audio" {
            GeometryReader { geometry in
                AlbumCover(id: player.currentItem?.previewId)
                    .frame(
                        width: albumCoverSize(geometry),
                        height: albumCoverSize(geometry)
                    )
                    .cornerRadius(5)
                    .shadow(radius: albumCoverSpacing(geometry) / 2)
                    .padding(albumCoverSpacing(geometry) / 2)
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ZStack {
                    playerFrame
                    albumCover
                }

                Spacer()

                PlayButton(player: player, size: 20)
                    .padding(.trailing)
            }

            Divider()
        }
        .frame(height: MiniPlayer.height)
        .foregroundColor(.white)
        .background {
            Rectangle()
                .fill(MiniPlayer.background)
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
            .withErrorHandling()
            .environmentObject(MediaPlayer.preview)
            .environmentObject(ObjectSource.preview)
    }
}

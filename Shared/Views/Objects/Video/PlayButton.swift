import SwiftUI

struct PlayButton: View {
    @EnvironmentObject private var player: MediaPlayer

    let size: CGFloat

    var body: some View {
        let action = player.isPlaying ? "pause" : "play"

        Button(action: { player.toggle() }) {
            Image(systemName: "\(action).fill")
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
        }
    }
}

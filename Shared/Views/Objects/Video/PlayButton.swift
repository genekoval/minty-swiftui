import SwiftUI

struct PlayButton: View {
    @ObservedObject var player: MediaPlayer

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

struct PlayButton_Previews: PreviewProvider {
    static var previews: some View {
        PlayButton(player: MediaPlayer.preview, size: 50)
    }
}

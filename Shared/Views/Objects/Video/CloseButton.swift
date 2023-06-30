import SwiftUI

struct CloseButton: View {
    @EnvironmentObject private var player: MediaPlayer

    let size: CGFloat

    var body: some View {
        Button(action: close) {
            Image(systemName: "x.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        }
    }

    private func close() {
        withAnimation {
            player.currentItem = nil
        }
    }
}

struct CloseButton_Previews: PreviewProvider {
    static var previews: some View {
        CloseButton(size: 50)
    }
}

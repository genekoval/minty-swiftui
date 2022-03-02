import AVKit
import Combine
import Minty
import SwiftUI

class PlayerView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }

    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }

    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}

struct CustomVideoPlayer: UIViewRepresentable {
    @ObservedObject var player: MediaPlayer

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.player = player.player
        context.coordinator.setController(view.playerLayer)
        return view
    }

    func updateUIView(_ uiView: PlayerView, context: Context) { }

    class Coordinator: NSObject, AVPictureInPictureControllerDelegate {
        private let parent: CustomVideoPlayer
        private var controller: AVPictureInPictureController?
        private var cancellable: AnyCancellable?

        init(_ parent: CustomVideoPlayer) {
            self.parent = parent
            super.init()

            cancellable = parent.player.$isPip.sink { [weak self] isPip in
                guard let self = self,
                      let controller = self.controller
                else { return }

                if isPip {
                    if !controller.isPictureInPictureActive {
                        controller.startPictureInPicture()
                    }
                }
                else if controller.isPictureInPictureActive {
                    controller.stopPictureInPicture()
                }
            }
        }

        func setController(_ playerLayer: AVPlayerLayer) {
            controller = AVPictureInPictureController(playerLayer: playerLayer)
            controller?.canStartPictureInPictureAutomaticallyFromInline = true
            controller?.delegate = self
        }

        func pictureInPictureControllerDidStartPictureInPicture(
            _ pictureInPictureController: AVPictureInPictureController
        ) {
            parent.player.isPip = true
        }

        func pictureInPictureControllerDidStopPictureInPicture(
            _ pictureInPictureController: AVPictureInPictureController
        ) {
            parent.player.isPip = false
        }
    }
}
struct MediaPlayerView: View {
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var player: MediaPlayer

    @State private var uiVisible = true

    @ViewBuilder
    private var background: some View {
        Color.black
            .ignoresSafeArea()
    }

    var body: some View {
        ZStack {
            background

            CustomVideoPlayer(player: player)
                .onTapGesture { toggleUI() }
                .overlay {
                    TimeJumpOverlay()
                        .onTapGesture { toggleUI() }
                }
                .overlay(alignment: .bottom) {
                    if uiVisible {
                        PlayerControls(player: player)
                    }
                    else {
                        EmptyView()
                    }
                }
                .overlay(alignment: .topLeading) {
                    if uiVisible {
                        dismissButton
                    }
                    else {
                        EmptyView()
                    }
                }
                .statusBar(hidden: !uiVisible)
        }
    }

    @ViewBuilder
    private var dismissButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "chevron.down")
                .foregroundColor(.white)
                .padding()
        }
    }

    private func toggleUI() {
        withAnimation {
            uiVisible.toggle()
        }
    }
}

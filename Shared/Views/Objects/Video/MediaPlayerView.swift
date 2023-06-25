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
    @EnvironmentObject var player: MediaPlayer

    @State private var offset: CGFloat = 0
    @State private var uiVisible = true

    @ViewBuilder
    private var albumCover: some View {
        if player.currentItem == nil || player.currentItem?.type == "audio" {
            AlbumCover(id: player.currentItem?.previewId)
                .cornerRadius(16)
                .shadow(radius: 10)
                .frame(width: 200, height: 200)
        }
    }

    @ViewBuilder
    private var background: some View {
        player.currentItem?.type == "video" ?
            .black :
            Color(.secondarySystemBackground)
    }

    var body: some View {
        ZStack {
            background
            playerView
            albumCover
            timeJumpOverlay

            if uiVisible {
                controls
            }
        }
        .statusBar(hidden: !uiVisible)
        .persistentSystemOverlays(uiVisible ? .automatic : .hidden)
        .cornerRadius(16)
        .offset(y: offset)
        .gesture(drag)
    }

    @ViewBuilder
    private var controls: some View {
        PlayerControls(player: player)
            .padding()
    }

    private var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = max(value.translation.height, 0)
            }
            .onEnded { value in
                let delta = value.predictedEndLocation.y - value.location.y

                if delta > 10 {
                    player.minimize()
                }
                else {
                    withAnimation {
                        offset = 0
                    }
                }
            }
    }

    @ViewBuilder
    private var playerView: some View {
        CustomVideoPlayer(player: player)
            .onTapGesture { toggleUI() }
    }

    @ViewBuilder
    private var timeJumpOverlay: some View {
        TimeJumpOverlay()
            .onTapGesture { toggleUI() }
    }

    private func toggleUI() {
        withAnimation {
            uiVisible.toggle()
        }
    }
}

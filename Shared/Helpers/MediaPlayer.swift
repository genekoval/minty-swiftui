import AVKit
import Combine
import Minty

private let timescale: CMTimeScale = 100

final class MediaPlayer: ObservableObject {
    @Published var isPip = false
    @Published var isPlaying = false
    @Published var isEditingTime = false
    @Published var isMaximized = false
    @Published var currentItem: ObjectPreview?
    @Published var currentTime: Double = .zero
    @Published var duration: Double?

    var errorHandler: ErrorHandler?
    let player = AVPlayer()
    var source: ObjectSource?

    private var cancellables = Set<AnyCancellable>()
    private var timeObserver: Any?
    private var wasPlaying = false

    init() {
        $isEditingTime
            .dropFirst()
            .sink { [weak self] editing in
                guard let self = self else { return }

                if editing {
                    self.startSeek()
                }
                else {
                    self.endSeek()
                }
            }
            .store(in: &cancellables)

        $currentTime
            .dropFirst()
            .sink { [weak self] time in
                guard let self = self else { return }
                guard self.isEditingTime else { return }

                self.seek(to: time)
            }
            .store(in: &cancellables)

        player
            .publisher(for: \.timeControlStatus)
            .sink { [weak self] status in
                switch status {
                case .playing:
                    self?.isPlaying = true
                case .paused:
                    self?.isPlaying = false
                case .waitingToPlayAtSpecifiedRate:
                    break
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)

        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(value: 1, timescale: timescale),
            queue: .main
        ) { [weak self] time in
            guard let self = self else { return }
            if self.isEditingTime == false {
                self.currentTime = time.seconds
            }
        }

        $currentItem
            .sink { [weak self] in self?.setCurrentItem(to: $0) }
            .store(in: &cancellables)

        setAudioSessionCategory(to: .playback)
    }

    deinit {
        if let timeObserver = timeObserver {
            player.removeTimeObserver(timeObserver)
        }
    }

    private func endSeek() {
        seek(to: currentTime)

        if wasPlaying {
            player.play()
        }
    }

    func jump(_ seconds: Double) {
        seek(to: currentTime + seconds)
    }

    func play() {
        if currentTime == duration {
            seek(to: 0)
        }

        player.play()
    }

    func pause() {
        player.pause()
    }

    private func seek(to seconds: Double) {
        player.seek(
            to: CMTime(
                seconds: seconds,
                preferredTimescale: timescale
            ),
            toleranceBefore: .zero,
            toleranceAfter: .zero
        )
    }

    private func setAudioSessionCategory(to value: AVAudioSession.Category) {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(value)
        }
        catch {
            fatalError("Setting audio session category failed: \(error)")
        }
    }

    private func setCurrentItem(to object: ObjectPreview?) {
        if object == currentItem { return }

        guard let object = object else {
            player.replaceCurrentItem(with: nil)
            return
        }

        var url: URL?

        do {
            url = try source?.url(for: object.id)
        }
        catch {
            errorHandler?.handle(error: error)
        }

        guard let url = url else { return }

        let asset = AVURLAsset(
            url: url,
            options: ["AVURLAssetOutOfBandMIMETypeKey": object.mimeType]
        )
        let item = AVPlayerItem(asset: asset)

        currentTime = .zero
        duration = nil
        player.replaceCurrentItem(with: item)

        item
            .publisher(for: \.status)
            .sink { [weak self] status in
                switch status {
                case .readyToPlay:
                    self?.duration = item.asset.duration.seconds
                case .failed:
                    if let error = item.error {
                        self?.errorHandler?.handle(error: error)
                    }
                default:
                    break
                }
            }
            .store(in: &cancellables)

        play()
    }

    private func startSeek() {
        wasPlaying = isPlaying
        player.pause()
    }

    func toggle() {
        isPlaying ? pause() : play()
    }
}
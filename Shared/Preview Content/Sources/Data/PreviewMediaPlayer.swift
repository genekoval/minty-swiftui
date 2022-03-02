extension MediaPlayer {
    static let preview: MediaPlayer = {
        let player = MediaPlayer()
        player.source = ObjectSource.preview
        return player
    }()
}

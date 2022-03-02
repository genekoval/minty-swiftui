import SwiftUI

private func makeFormatter() -> DateComponentsFormatter {
    let formatter = DateComponentsFormatter()

    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = .pad

    return formatter
}

private let minutesFormatter: DateComponentsFormatter = {
    let formatter = makeFormatter()

    formatter.allowedUnits = [.minute, .second]

    return formatter
}()

private let hoursFormatter: DateComponentsFormatter = {
    let formatter = makeFormatter()

    formatter.allowedUnits = [.hour, .minute, .second]

    return formatter
}()

struct PlayerControls: View {
    @ObservedObject var player: MediaPlayer

    @ViewBuilder
    private var background: some View {
        LinearGradient(
            colors: [.black.opacity(0.8), .black.opacity(0)],
            startPoint: .bottom,
            endPoint: .top
        )
    }

    var body: some View {
        VStack {
            slider
            playButton
        }
        .foregroundColor(.white)
        .background(background)
    }

    @ViewBuilder
    private var playButton: some View {
        PlayButton(player: player, size: 30)
            .padding()
    }

    @ViewBuilder
    private var slider: some View {
        let duration = player.duration ?? 0

        VStack {
            Slider(
                value: $player.currentTime,
                in: 0...duration,
                onEditingChanged: { isEditing in
                    player.isEditingTime = isEditing
                }
            )
            .tint(.white)

            HStack {
                Text(formatTime(player.currentTime, duration))

                Spacer()

                Text(formatTime(duration, duration))
            }
            .font(.caption)
        }
        .padding()
    }

    private func formatTime(_ seconds: Double, _ total: Double) -> String {
        guard player.duration != nil else { return "--:--" }

        let formatter = total < 3600 ? minutesFormatter : hoursFormatter
        return formatter.string(from: TimeInterval(seconds))!
    }
}

struct PlayerControls_Previews: PreviewProvider {
    static var previews: some View {
        PlayerControls(player: MediaPlayer.preview)
    }
}

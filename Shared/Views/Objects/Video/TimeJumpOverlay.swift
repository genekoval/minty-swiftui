import SwiftUI

private let animationDuration = 0.25

enum JumpDirection {
    case backward
    case forward

    var description: String {
        switch self {
        case .backward: return "backward"
        case .forward: return "forward"
        }
    }
}

private struct TimeJumpZone: View {
    @EnvironmentObject var player: MediaPlayer

    let direction: JumpDirection

    @State private var amount: Double = 15
    @State private var visible = false

    @ViewBuilder
    private var background: some View {
        Color
            .clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                background
                symbol(geometry: geometry)
            }
            .onTapGesture(count: 2, perform: jump)
        }
    }

    private func jump() {
        visible = true
        player.jump(amount * (direction == .backward ? -1 : 1))

        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            visible = false
        }
    }

    @ViewBuilder
    private func symbol(geometry: GeometryProxy) -> some View {
        Image(systemName: "go\(direction.description).\(Int(amount))")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: geometry.size.width / 4)
            .foregroundColor(.white)
            .opacity(visible ? 1 : 0)
            .shadow(radius: 2)
            .animation(.easeInOut(duration: animationDuration), value: visible)
    }
}

struct TimeJumpOverlay: View {
    var body: some View {
        HStack {
            TimeJumpZone(direction: .backward)
            TimeJumpZone(direction: .forward)
        }
    }
}

struct TimeJumpOverlay_Previews: PreviewProvider {
    static var previews: some View {
        TimeJumpOverlay()
            .background(.black)
            .environmentObject(MediaPlayer.preview)
    }
}

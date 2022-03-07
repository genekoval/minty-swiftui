import SwiftUI

private struct SwipeToDismiss: ViewModifier {
    @EnvironmentObject var overlay: Overlay

    let active: Bool

    @State private var previousOffset: CGSize = .zero

    @GestureState(resetTransaction: Transaction(animation: .easeOut))
    private var offset: CGSize = .zero

    private var drag: some Gesture {
        DragGesture(minimumDistance: 25, coordinateSpace: .local)
            .updating($offset) { (value, state, transaction) in
                state = value.translation

                let height = state.height / 1000
                overlay.opacity = clamp(1.0 - height, 0.0, 1.0)
            }
            .onChanged { value in
                previousOffset = value.translation
            }
            .onEnded { value in
                overlay.opacity = 1.0

                let direction = SwipeDirection(
                    start: previousOffset,
                    end: value.translation
                )

                if value.translation.height > 0 && direction != .up {
                    overlay.hide()
                }
            }
    }

    func body(content: Content) -> some View {
        content
            .offset(offset)
            .gesture(active ? drag : nil)
    }
}

extension View {
    func swipeToDismiss(active: Bool = true) -> some View {
        modifier(SwipeToDismiss(active: active))
    }
}

import SwiftUI

private struct SwipeToDismiss: ViewModifier {
    @EnvironmentObject var overlay: Overlay

    let active: Bool

    @State private var offset: CGSize = .zero

    private var drag: some Gesture {
        DragGesture(minimumDistance: 25, coordinateSpace: .local)
            .onChanged { value in
                offset = value.translation

                let height = offset.height / 1000
                overlay.opacity = clamp(1.0 - height, 0.0, 1.0)
            }
            .onEnded { value in
                let direction = SwipeDirection(
                    start: offset,
                    end: value.translation
                )

                withAnimation(.easeOut) {
                    offset = .zero
                    overlay.opacity = 1.0
                }

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

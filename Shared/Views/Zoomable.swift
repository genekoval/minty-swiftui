import SwiftUI

/// Constrains a value between the limits.
func clamp(
    _ value: CGFloat,
    _ minValue: CGFloat,
    _ maxValue: CGFloat
) -> CGFloat {
    min(maxValue, max(minValue, value))
}

private struct Zoomable: ViewModifier {
    let minScale: CGFloat
    let maxScale: CGFloat

    @Binding var scale: CGFloat

    @State private var currentScale = 0.0
    @State private var offset: CGSize = .zero

    @GestureState private var dragOffset: CGSize = .zero

    init(
        scale: Binding<CGFloat>,
        minScale: CGFloat,
        maxScale: CGFloat
    ) {
        _scale = scale
        self.minScale = minScale
        self.maxScale = maxScale
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale + currentScale)
            .offset(
                x: offset.width + dragOffset.width,
                y: offset.height + dragOffset.height
            )
            .animation(.default, value: scale)
            .onTapGesture(count: 2) {
                scale == 1 ? quickZoom() : reset()
            }
            .simultaneousGesture(
                MagnificationGesture()
                    .onChanged { amount in
                        currentScale = amount - 1
                    }
                    .onEnded { amount in
                        let scale = self.scale + currentScale
                        self.scale = clamp(scale, minScale, maxScale)
                        if self.scale <= 1 {
                            offset = .zero
                        }
                        currentScale = 0
                    }
            )
            .simultaneousGesture(scale == 1 ? nil :
                DragGesture()
                    .updating($dragOffset) { (value, state, transaction) in
                        state = value.translation
                    }
                    .onEnded { value in
                        offset.width += value.translation.width
                        offset.height += value.translation.height
                    }
            )
    }

    private func quickZoom() {
        scale = clamp(2, minScale, maxScale)
    }

    private func reset() {
        scale = clamp(1, minScale, maxScale)
        offset = .zero
    }
}

extension View {
    func zoomable(
        scale: Binding<CGFloat>,
        minScale: CGFloat = 0.5,
        maxScale: CGFloat = 3
    ) -> some View {
        modifier(Zoomable(scale: scale, minScale: minScale, maxScale: maxScale))
    }
}

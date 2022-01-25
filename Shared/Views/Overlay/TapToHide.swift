import SwiftUI

private struct TapToHide: ViewModifier {
    @EnvironmentObject var overlay: Overlay

    @ViewBuilder
    private var background: some View {
        Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
    }

    func body(content: Content) -> some View {
        ZStack {
            background
                .onTapGesture(perform: toggleUI)

            content
                .onTapGesture(perform: toggleUI)
        }
    }

    private func toggleUI() {
        withAnimation(.default.speed(2)) {
            overlay.uiVisible.toggle()
        }
    }
}

extension View {
    func tapToHide() -> some View {
        modifier(TapToHide())
    }
}

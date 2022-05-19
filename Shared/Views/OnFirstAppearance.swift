import SwiftUI

private struct OnFirstAppearance: ViewModifier {
    let action: () -> Void

    @State private var done = false

    func body(content: Content) -> some View {
        content
            .onAppear {
                if !done {
                    action()
                    done = true
                }
            }
    }
}

extension View {
    func onFirstAppearance(action: @escaping () -> Void) -> some View {
        modifier(OnFirstAppearance(action: action))
    }
}

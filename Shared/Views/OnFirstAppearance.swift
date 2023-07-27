import SwiftUI

private struct OnFirstAppearance: ViewModifier {
    let perform: () -> Void

    @State private var done = false

    func body(content: Content) -> some View {
        content
            .onAppear {
                if !done {
                    perform()
                    done = true
                }
            }
    }
}

extension View {
    func onFirstAppearance(perform: @escaping () -> Void) -> some View {
        modifier(OnFirstAppearance(perform: perform))
    }
}

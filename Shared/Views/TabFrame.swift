import SwiftUI

struct Size: PreferenceKey {
    typealias Value = [CGRect]

    static var defaultValue: [CGRect] = []

    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}


struct TabFrame<Content>: View where Content : View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        GeometryReader { geometry in
            content()
                .preference(
                    key: Size.self,
                    value: [geometry.frame(in: CoordinateSpace.global)]
                )
        }
    }
}

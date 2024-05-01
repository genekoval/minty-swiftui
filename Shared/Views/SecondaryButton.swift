import SwiftUI

struct SecondaryButton<Label>: View where Label : View {
    private let action: () -> Void
    private let label: Label

    var body: some View {
        Button(action: action) {
            ZStack {
                background
                label.padding()
            }
        }
    }

    @ViewBuilder
    private var background: some View {
        RoundedRectangle(cornerRadius: 10)
            .foregroundStyle(Color(.secondarySystemBackground))
    }

    init(action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }
}

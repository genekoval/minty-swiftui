import SwiftUI

struct SelectableRow<Content>: View where Content : View {
    @Binding var isSelected: Bool

    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack {
            Button(action: toggle) {
                Checkmark(isChecked: isSelected)
            }

            content()
        }
    }

    private func toggle() {
        withAnimation {
            isSelected.toggle()
        }
    }
}

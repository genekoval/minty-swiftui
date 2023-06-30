import SwiftUI

struct SelectableRow<Content>: View where Content : View {
    let onSelected: () -> Void
    let onDeselected: () -> Void

    @ViewBuilder let content: () -> Content

    @State private var isSelected = false

    var body: some View {
        Row {
            HStack {
                Button(action: toggle) {
                    Checkmark(isChecked: isSelected)
                }

                content()
            }
        }
    }

    private func toggle() {
        withAnimation {
            isSelected.toggle()
        }

        if isSelected {
            onSelected()
        }
        else {
            onDeselected()
        }
    }
}

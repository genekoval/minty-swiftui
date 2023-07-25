import SwiftUI

struct SelectableRow<Content>: View where Content : View {
    let onSelected: () -> Void
    let onDeselected: () -> Void

    @ViewBuilder let content: () -> Content

    @State private var isSelected = false

    var body: some View {
        HStack {
            Button(action: toggle) {
                Checkmark(isChecked: isSelected)
            }

            content()
        }
        .onChange(of: isSelected, perform: selectionChanged)
    }

    private func selectionChanged(_ selected: Bool) {
        if selected {
            onSelected()
        }
        else {
            onDeselected()
        }
    }

    private func toggle() {
        withAnimation {
            isSelected.toggle()
        }
    }
}

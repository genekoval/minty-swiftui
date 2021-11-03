import SwiftUI

struct SelectButton: View {
    @Binding var isSelected: Bool

    var body: some View {
        Button(action: {
            isSelected.toggle()
        }) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(
                    isSelected ? Color.accentColor : Color.secondary
                )
        }
    }
}

struct SelectButton_Previews: PreviewProvider {
    private struct Preview: View {
        @State private var isSelected = false

        var body: some View {
            SelectButton(isSelected: $isSelected)
        }
    }

    static var previews: some View {
        Preview()
    }
}

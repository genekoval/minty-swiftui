import SwiftUI

struct SelectionIndicator: View {
    let isSelected: Bool

    var body: some View {
        if isSelected {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.accentColor)
                .background {
                    Circle()
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 1, x: 0, y: 1)
                }
        }
        else {
            Image(systemName: "circle")
                .font(.title2)
                .foregroundColor(.white)
                .shadow(color: .black, radius: 1, x: 0, y: 1)
        }
    }
}

struct SelectButton: View {
    @Binding var isSelected: Bool

    var body: some View {
        Button(action: { isSelected.toggle() }) {
            SelectionIndicator(isSelected: isSelected)
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

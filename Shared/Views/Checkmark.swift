import SwiftUI

struct Checkmark: View {
    let isChecked: Bool

    var body: some View {
        if isChecked {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.accentColor)
        }
        else {
            Image(systemName: "circle")
                .foregroundColor(.secondary)
        }
    }
}

struct Checkmark_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Checkmark(isChecked: true)
            Checkmark(isChecked: false)
        }
    }
}

import SwiftUI

struct Checkmark: View {
    let isChecked: Bool

    var body: some View {
        Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
            .foregroundColor(isChecked ? .accentColor : .secondary)
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

import SwiftUI

struct CancelButton: View {
    let action: () -> Void

    var body: some View {
        Button("Cancel", action: action)
    }
}

struct CancelButton_Previews: PreviewProvider {
    static var previews: some View {
        CancelButton() { }
    }
}

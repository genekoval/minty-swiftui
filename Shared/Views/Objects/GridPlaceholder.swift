import SwiftUI

struct GridPlaceholder: View {
    var body: some View {
        Image(systemName: "square.dashed")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.secondary)
            .frame(width: 50)
    }
}

struct GridPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        GridPlaceholder()
    }
}

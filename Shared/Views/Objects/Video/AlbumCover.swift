import SwiftUI

struct AlbumCover: View {
    let id: UUID?

    var body: some View {
        ImageObject(id: id) {
            Image(systemName: "music.note")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .foregroundColor(.amazon)
                .background(Color.darkJungleGreen)
        }
    }
}

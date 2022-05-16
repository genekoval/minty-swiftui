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

struct AlbumCover_Previews: PreviewProvider {
    private struct Preview: View {
        let id: UUID?

        var body: some View {
            ZStack {
                Color(.secondarySystemBackground)
                AlbumCover(id: id)
                    .frame(width: 200, height: 200)
            }
        }
    }

    static var previews: some View {
        Group {
            Preview(id: nil)

            Preview(id: PreviewObject.sandDune)
        }
        .withErrorHandling()
        .environmentObject(ObjectSource.preview)
        .preferredColorScheme(.dark)
    }
}

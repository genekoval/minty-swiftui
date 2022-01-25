import SwiftUI

struct ObjectReel: View {
    @EnvironmentObject var overlay: Overlay

    var body: some View {
        PageView(
            pages: overlay.objects.map { ObjectViewer(object: $0) },
            currentPage: $overlay.index
        )
    }
}

struct ObjectReel_Previews: PreviewProvider {
    static var previews: some View {
        ObjectReel()
            .environmentObject(Overlay())
    }
}

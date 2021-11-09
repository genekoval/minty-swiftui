import SwiftUI

struct ObjectUploadButton: View {
    let onUpload: ([String]) -> Void

    @State private var objects: [String] = []
    @State private var showingUploadView = false

    var body: some View {
        Button(action: { showingUploadView.toggle() }) {
            Image(systemName: "doc.badge.plus")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .sheet(isPresented: $showingUploadView) {
            NavigationView {
                ObjectUploadView(onUpload: onUpload)
            }
        }
    }
}

struct ObjectUploadButton_Previews: PreviewProvider {
    static var previews: some View {
        ObjectUploadButton(onUpload: { objects in })
            .frame(width: 50)
            .environmentObject(ObjectSource.preview)
    }
}

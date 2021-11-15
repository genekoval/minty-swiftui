import Minty
import SwiftUI

struct ObjectUploadView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var source: ObjectSource

    let onUpload: ([String]) -> Void

    @State private var text = ""
    @State private var uploads: [Uploadable] = []

    var body: some View {
        VStack {
            List {
                ForEach(uploads) {
                    uploadView($0)
                }
                .onDelete { offsets in
                    if let index = offsets.first {
                        uploads.remove(at: index)
                    }
                }
            }

            VStack {
                ClearableTextField("Object ID or URL", text: $text)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .submitLabel(.done)
                    .onSubmit { textSubmitted() }
            }
            .padding()
        }
        .navigationTitle("Add Objects")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if !uploads.isEmpty {
                    Button(action: { upload() }) {
                        Text("Add")
                            .bold()
                    }
                }
            }

            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
    }

    private func textSubmitted() {
        uploads.append(source.makeUploadable(text: text))
        text.removeAll()
    }

    private func upload() {
        var objects: [String] = []

        if let repo = source.repo {
            for item in uploads {
                item.upload(objects: &objects, repo: repo)
            }
        }

        if !objects.isEmpty {
            onUpload(objects)
        }

        dismiss()
    }

    @ViewBuilder
    private func uploadView(_ upload: Uploadable) -> some View {
        switch upload {
        case .existingObject(let objectId):
            Label(objectId, systemImage: "doc")
        case .url(let urlString):
            Label(urlString, systemImage: "network")
        }
    }
}

struct ObjectUploadView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ObjectUploadView(onUpload: { objects in })
        }
        .environmentObject(ObjectSource.preview)
    }
}

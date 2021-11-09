import SwiftUI

private enum Uploadable: Identifiable {
    case existingObject(String)

    var id: String {
        switch self {
        case .existingObject(let objectId):
            return objectId
        }
    }

    func upload(objects: inout [String], source: ObjectSource) {
        switch self {
        case .existingObject(let objectId):
            objects.append(objectId)
        }
    }
}

struct ObjectUploadView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var source: ObjectSource

    let onUpload: ([String]) -> Void

    @State private var uploads: [Uploadable] = []
    @State private var id = ""

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
                ClearableTextField("Object ID", text: $id, icon: "doc")
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .submitLabel(.done)
                    .onSubmit {
                        uploads.append(.existingObject(id))
                        id.removeAll()
                    }
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

    private func upload() {
        var objects: [String] = []

        for item in uploads {
            item.upload(objects: &objects, source: source)
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

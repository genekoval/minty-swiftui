import Minty
import SwiftUI

struct ObjectUploadView: View {
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var errorHandler: ErrorHandler
    @EnvironmentObject var source: ObjectSource

    let onUpload: ([ObjectPreview]) throws -> Void

    @State private var imageURL: URL?
    @State private var inputImage: UIImage?
    @State private var showingFileImporter = false
    @State private var showingImagePicker = false
    @State private var text = ""
    @State private var uploads: [Uploadable] = []

    var body: some View {
        VStack {
            List {
                ForEach(uploads) {
                    $0.view()
                }
                .onMove { (source, destination) in
                    uploads.move(fromOffsets: source, toOffset: destination)
                }
                .onDelete { offsets in
                    if let index = offsets.first {
                        uploads.remove(at: index)
                    }
                }
            }
            .environment(\.editMode, .constant(.active))

            VStack {
                ClearableTextField("Object ID or URL", text: $text)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .submitLabel(.done)
                    .onSubmit { textSubmitted() }

                HStack(spacing: 50) {
                    Button(action: { showingImagePicker = true }) {
                        Image(systemName: "photo.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50)
                    }

                    Button(action: { showingFileImporter = true }) {
                        Image(systemName: "folder.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50)
                    }
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
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: $inputImage, url: $imageURL)
        }
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: [.item],
            allowsMultipleSelection: true,
            onCompletion: loadFile
        )
    }

    private func loadFile(result: Result<[URL], Error>) {
        errorHandler.handle {
            let urls = try result.get()
            uploads.append(contentsOf: urls.map { .file($0) })
        }
    }

    private func loadImage() {
        guard let inputImage = inputImage else { return }
        guard let imageURL = imageURL else { return }

        uploads.append(.image(inputImage, imageURL))
    }

    private func textSubmitted() {
        do {
            uploads.append(try source.makeUploadable(text: text))
            text.removeAll()
        }
        catch {
            errorHandler.handle(error: error)
        }
    }

    private func upload() {
        Task {
            var objects: [ObjectPreview] = []

            for item in uploads {
                do {
                    try await item.upload(objects: &objects, source: source)
                }
                catch {
                    errorHandler.handle(error: error)
                    return
                }
            }

            if !objects.isEmpty {
                do {
                    try onUpload(objects)
                }
                catch {
                    errorHandler.handle(error: error)
                    return
                }
            }

            dismiss()
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

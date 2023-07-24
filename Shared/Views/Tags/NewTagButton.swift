import SwiftUI

private struct NewTag: View {
    @EnvironmentObject private var data: DataSource
    @EnvironmentObject private var errorHandler: ErrorHandler

    @Binding var name: String
    @Binding var tag: TagViewModel?

    let onCreated: (TagViewModel) -> Void

    @State private var creating = false

    var body: some View {
        Form {
            TextField("Name", text: $name)
                .onSubmit(createTag)
                .submitLabel(.done)
        }
        .navigationTitle("New Tag")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if creating {
                ProgressView()
            }
            else {
                Button(action: createTag) {
                    Text("Add")
                        .bold()
                }
                .disabled(name.trimmed == nil)
            }
        }
    }

    private func createTag() {
        guard let name = name.trimmed else { return }

        errorHandler.handle {
            creating = true
            defer { creating = false }

            let tag = try await data.addTag(name: name)

            self.name.removeAll()
            self.tag = tag

            onCreated(tag)
        }
    }
}

private struct NewTagHost: View {
    @Binding var name: String
    @Binding var tag: TagViewModel?

    let onCreated: (TagViewModel) -> Void

    var body: some View {
        if let tag {
            TagHost(tag: tag)
        }
        else {
            NewTag(name: $name, tag: $tag, onCreated: onCreated)
        }
    }
}

struct NewTagButton: View {
    @State private var name = ""
    @State private var tag: TagViewModel?

    let onCreated: (TagViewModel) -> Void

    var body: some View {
        NavigationLink(destination: NewTagHost(
            name: $name,
            tag: $tag,
            onCreated: onCreated
        )) {
            Image(systemName: "plus")
        }
        .onAppear { tag = nil }
    }
}

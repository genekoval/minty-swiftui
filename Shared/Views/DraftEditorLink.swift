import SwiftUI

private struct DraftEditor: View {
    @EnvironmentObject var errorHandler: ErrorHandler

    let title: String
    let original: String?
    let onSave: () async throws -> Void

    @Binding var draft: String

    @FocusState private var editorIsFocused: Bool

    var body: some View {
        TextEditor(text: $draft)
            .focused($editorIsFocused)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(title)
            .padding()
            .toolbar {
                HStack {
                    if draftChanged {
                        Button(action: { reset() }) {
                            Image(systemName: "arrow.uturn.backward.circle")
                        }
                    }

                    if draftChanged || editorIsFocused {
                        Button(action: { done() }) {
                            Text(draftChanged ? "Save" : "Done")
                                .bold()
                        }
                    }
                }
            }
    }

    private var draftChanged: Bool {
        draft != (original ?? "")
    }

    private func done() {
        save()
        editorIsFocused = false
    }

    private func reset() {
        draft = original ?? ""
        editorIsFocused = false
    }

    private func save() {
        guard draftChanged else { return }

        errorHandler.handle {
            try await onSave()
        }
    }
}

struct DraftEditorLink: View {
    let title: String
    let original: String?
    let onSave: () async throws -> Void

    @Binding var draft: String

    var body: some View {
        Section(header: Text(title)) {
            NavigationLink(destination: DraftEditor(
                title: title,
                original: original,
                onSave: onSave,
                draft: $draft
            )) {
                if let text = original {
                    Text(text)
                        .lineLimit(1)
                }
                else {
                    Text("No \(title.lowercased())")
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
        }
    }
}

struct DraftEditorLink_Previews: PreviewProvider {
    private struct Preview: View {
        @StateObject private var tag =
            TagViewModel.preview(id: PreviewTag.helloWorld)

        var body: some View {
            NavigationView {
                Form {
                    DraftEditorLink(
                        title: "Description",
                        original: tag.description,
                        onSave: {
                            try await tag.commitDescription()
                        },
                        draft: $tag.draftDescription
                    )
                }
                .navigationTitle("Edit Tag")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    static var previews: some View {
        Preview()
            .withErrorHandling()
    }
}

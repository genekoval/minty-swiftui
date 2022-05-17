import SwiftUI

private struct DraftEditor: View {
    let title: String
    let original: String?
    let onSave: () -> Void

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
        if draftChanged { onSave() }
        editorIsFocused = false
    }

    private func reset() {
        draft = original ?? ""
        editorIsFocused = false
    }
}

struct DraftEditorLink: View {
    let title: String
    let original: String?
    let onSave: () -> Void

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
        @EnvironmentObject var errorHandler: ErrorHandler

        @StateObject private var tag =
            TagViewModel.preview(id: PreviewTag.helloWorld)

        var body: some View {
            NavigationView {
                Form {
                    DraftEditorLink(
                        title: "Description",
                        original: tag.description,
                        onSave: {
                            errorHandler.handle { try tag.commitDescription() }
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

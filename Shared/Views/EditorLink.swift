import SwiftUI

private struct EditorView: View {
    let title: String
    let onSave: () -> Void
    @Binding var draft: String
    let original: String?

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

struct EditorLink: View {
    let title: String
    let onSave: () -> Void
    @Binding var draft: String
    let original: String?

    var body: some View {
        Section(header: Text(title)) {
            NavigationLink(destination: EditorView(
                title: title,
                onSave: onSave,
                draft: $draft,
                original: original
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

struct EditorLink_Previews: PreviewProvider {
    private struct Preview: View {
        @StateObject private var tag = TagViewModel.preview(
            id: "1",
            deleted: Deleted()
        )

        var body: some View {
            NavigationView {
                Form {
                    EditorLink(
                        title: "Description",
                        onSave: { tag.commitDescription() },
                        draft: $tag.draftDescription,
                        original: tag.description
                    )
                }
                .navigationTitle("Edit Tag")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    static var previews: some View {
        Preview()
    }
}

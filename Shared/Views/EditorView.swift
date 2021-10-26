import SwiftUI

struct EditorView: View {
    let title: String
    let save: () -> Void
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
        let original = original ?? ""
        return original != draft
    }

    private func done() {
        if draftChanged { save() }
        editorIsFocused = false
    }

    private func reset() {
        draft = original ?? ""
        editorIsFocused = false
    }
}

struct EditorView_Previews: PreviewProvider {
    @StateObject private static var tag = TagViewModel.preview(id: "1")

    static var previews: some View {
        NavigationView {
            EditorView(
                title: "Description",
                save: { tag.commitDescription() },
                draft: $tag.draftDescription,
                original: tag.description
            )
        }
    }
}

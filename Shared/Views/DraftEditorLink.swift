import SwiftUI

private struct DraftEditorView: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var errorHandler: ErrorHandler

    @Binding var draft: String

    let original: String?
    let onSave: () async throws -> Void

    @FocusState private var editorIsFocused: Bool

    var body: some View {
        TextEditor(text: $draft)
            .focused($editorIsFocused)
            .padding(.horizontal)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if draftChanged {
                        Button(action: save) {
                            Text("Save")
                                .bold()
                        }
                    }
                    else if editorIsFocused {
                        Button(action: { editorIsFocused = false }) {
                            Text("Done")
                                .bold()
                        }
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    if draftChanged {
                        Button("Reset", action: reset)
                    }
                    else {
                        DismissButton()
                    }
                }

                ToolbarItem(placement: .bottomBar) {
                    Text("\(draft.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
    }

    private var draftChanged: Bool {
        draft != (original ?? "")
    }

    private func reset() {
        draft = original ?? ""
        editorIsFocused = false
    }

    private func save() {
        errorHandler.handle {
            try await onSave()
            dismiss()
        }
    }
}

struct DraftEditor: View {
    @Binding var draft: String

    let original: String?
    let title: String
    let onSave: () async throws -> Void

    @State private var isPresented = false

    var body: some View {
        Section(content: {
            Button(action: { isPresented = true }) {
                if let original {
                    Text(original)
                        .lineLimit(1)
                }
                else {
                    Text("No \(title.lowercased())")
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
        }, header: {
            HStack {
                Text(title)

                if let original {
                    Spacer()
                    Text("\(original.count)")
                }
            }
            .foregroundColor(.secondary)
        })
        .foregroundColor(.primary)
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                DraftEditorView(
                    draft: $draft,
                    original: original,
                    onSave: onSave
                )
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

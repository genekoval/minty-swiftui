import SwiftUI

struct CommentEditor: View {
    @Environment(\.dismiss) var dismiss

    let type: String
    @Binding var draft: String
    let onDone: () -> Void

    var body: some View {
        NavigationView {
            TextEditor(text: $draft)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("\(type) Comment")
                .padding(.horizontal)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) { doneButton }
                    ToolbarItem(placement: .cancellationAction) { cancelButton }
                }
        }
    }

    @ViewBuilder
    private var cancelButton: some View {
        Button("Cancel") { dismiss() }
    }

    @ViewBuilder
    private var doneButton: some View {
        Button(action: { done() }) {
            Text("Done")
                .bold()
        }
        .disabled(draft.isWhitespace)
    }

    private func done() {
        onDone()
        dismiss()
    }
}

struct CommentEditor_Previews: PreviewProvider {
    static var previews: some View {
        CommentEditor(type: "New", draft: .constant("")) { }
    }
}

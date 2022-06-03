import SwiftUI

struct CommentEditor: View {
    @EnvironmentObject var errorHandler: ErrorHandler

    let type: String

    @Binding var draft: String

    let onDone: () async throws -> Void

    var body: some View {
        SheetView(title: "\(type) Comment", done: (
            label: "Done",
            action: onDone,
            disabled: { draft.isWhitespace }
        )) {
            TextEditor(text: $draft)
                .padding(.horizontal)
        }
    }
}

struct CommentEditor_Previews: PreviewProvider {
    private struct Preview: View {
        @State private var draft = ""

        var body: some View {
            CommentEditor(type: "New", draft: $draft) { }
        }
    }

    static var previews: some View {
        CommentEditor(type: "New", draft: .constant("")) { }
    }
}

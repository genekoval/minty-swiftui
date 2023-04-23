import SwiftUI

private struct EditorView: View {
    let title: String

    @Binding var text: String

    var body: some View {
        TextEditor(text: $text)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(title)
            .padding()
    }
}

struct EditorLink: View {
    let title: String

    @Binding var text: String

    var body: some View {
        Section(header: Text(title)) {
            NavigationLink(destination: EditorView(
                title: title,
                text: $text
            )) {
                if text.isWhitespace {
                    Text("No \(title.lowercased())")
                        .foregroundColor(.secondary)
                        .italic()
                }
                else {
                    Text(text)
                        .lineLimit(1)
                }
            }
        }
    }
}

struct EditorLink_Previews: PreviewProvider {
    private struct Preview: View {
        @State private var text = ""

        var body: some View {
            NavigationView {
                Form {
                    EditorLink(title: "Title", text: $text)
                }
                .navigationTitle("New Post")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    static var previews: some View {
        Preview()
    }
}

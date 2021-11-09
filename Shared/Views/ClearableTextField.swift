import SwiftUI

struct ClearableTextField: View {
    let titleKey: LocalizedStringKey
    let icon: String?

    @Binding var text: String

    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
            }

            TextField(titleKey, text: $text)
                .foregroundColor(.primary)

            Button(action: { text.removeAll() }) {
                Image(systemName: "xmark.circle.fill")
                    .opacity(text.isEmpty ? 0 : 1)
            }
        }
        .padding(EdgeInsets(
            top: 8,
            leading: 6,
            bottom: 8,
            trailing: 6
        ))
        .foregroundColor(.secondary)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10.0)
    }

    init(
        _ titleKey: LocalizedStringKey,
        text: Binding<String>,
        icon: String? = nil
    ) {
        self.titleKey = titleKey
        _text = text
        self.icon = icon
    }
}

struct ClearableTextField_Previews: PreviewProvider {
    private struct Preview: View {
        let icon: String?

        @State private var text = ""

        var body: some View {
            ClearableTextField("Text", text: $text, icon: icon)
        }
    }

    static var previews: some View {
        Group {
            Preview(icon: nil)

            Preview(icon: "magnifyingglass")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

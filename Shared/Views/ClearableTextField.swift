import SwiftUI

struct ClearableTextField: View {
    private let titleKey: LocalizedStringKey
    private let icon: String?

    @Binding private var text: String

    @FocusState private var focused: Bool

    var body: some View {
        HStack {
            HStack {
                if let icon {
                    Image(systemName: icon)
                }

                TextField(titleKey, text: $text)
                    .focused($focused)
                    .foregroundColor(.primary)

                Button(action: clear) {
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

            if focused {
                Button("Cancel") {
                    withAnimation {
                        focused = false
                    }
                }
            }
        }
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

    private func clear() {
        text.removeAll()
        focused = true
    }
}

struct SearchField: View {
    private let titleKey: LocalizedStringKey

    @Binding private var text: String

    var body: some View {
        ClearableTextField(titleKey, text: $text, icon: "magnifyingglass")
    }

    init(
        _ titleKey: LocalizedStringKey = "Search",
        text: Binding<String>
    ) {
        self.titleKey = titleKey
        _text = text
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

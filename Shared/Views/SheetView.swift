import SwiftUI

struct SheetView<Content>: View where Content : View {
    typealias Done = (
        label: String,
        action: () throws -> Void,
        disabled: (() -> Bool)?
    )

    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var errorHandler: ErrorHandler

    let content: Content
    let done: Done?
    let title: String

    var body: some View {
        NavigationView {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) { doneButton }
                    ToolbarItem(placement: .cancellationAction) { cancelButton }
                }
        }
    }

    @ViewBuilder
    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
    }

    @ViewBuilder
    private var doneButton: some View {
        if let done = done {
            Button(action: {
                do {
                    try done.action()
                    dismiss()
                }
                catch {
                    errorHandler.handle(error: error)
                }
            }) {
                Text(done.label)
                    .bold()
            }
            .disabled(done.disabled?() ?? false)
        }
    }

    init(
        title: String,
        done: Done? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
        self.done = done
    }
}

struct SheetView_Previews: PreviewProvider {
    private struct Preview: View {
        @State private var ready = false

        var body: some View {
            SheetView(title: "Preview", done: (
                label: "Done",
                action: { },
                disabled: { !ready }
            )) {
                Form {
                    Toggle("Send read receipts", isOn: $ready)
                }
            }
        }
    }

    static var previews: some View {
        Preview()
    }
}

import SwiftUI

private struct DeleteConfirmation: ViewModifier {
    let item: String
    let action: () -> Void

    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        content
            .confirmationDialog(
                "Delete \(item)?",
                isPresented: $isPresented,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive, action: action)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
    }
}

extension View {
    func deleteConfirmation(
        _ item: String,
        isPresented: Binding<Bool>,
        action: @escaping () -> Void
    ) -> some View {
        modifier(DeleteConfirmation(
            item: item,
            action: action,
            isPresented: isPresented
        ))
    }
}

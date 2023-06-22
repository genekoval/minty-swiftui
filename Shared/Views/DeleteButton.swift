import SwiftUI

struct DeleteButton: View {
    let action: () -> Void
    let resource: String

    @State private var showingConfirmation = false

    var body: some View {
        Button("Delete \(resource)", role: .destructive) {
            showingConfirmation.toggle()
        }
        .confirmationDialog(
            "Delete this \(resource.lowercased())?",
            isPresented: $showingConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) { action() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    init(for resource: String, action: @escaping () -> Void) {
        self.resource = resource
        self.action = action
    }
}

struct DeleteButton_Previews: PreviewProvider {
    private struct Preview: View {
        @State private var showingAlert = false

        var body: some View {
            Form {
                DeleteButton(for: "Item") { showingAlert.toggle() }
            }
            .alert(Text("Item deleted."), isPresented: $showingAlert) { }
        }
    }

    static var previews: some View {
        Preview()
    }
}

import SwiftUI

struct DeleteButton: View {
    let action: () -> Void
    let resource: String

    @State private var showingAlert = false

    var body: some View {
        Section {
            Button("Delete \(resource)", role: .destructive) {
                showingAlert.toggle()
            }
        }
        .alert(
            Text("Delete this \(resource.lowercased())?"),
            isPresented: $showingAlert
        ) {
            Button("Delete", role: .destructive) { action() }
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

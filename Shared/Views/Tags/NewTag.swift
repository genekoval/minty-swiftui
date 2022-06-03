import Minty
import SwiftUI

struct NewTag: View {
    @EnvironmentObject var data: DataSource
    @EnvironmentObject var errorHandler: ErrorHandler

    let onCreated: (Tag.ID) -> Void

    @State private var name = ""

    var body: some View {
        SheetView(title: "New Tag", done: (
            label: "Done",
            action: create,
            disabled: { name.isWhitespace }
        )) {
            Form {
                HStack(spacing: 20) {
                    Text("Name")
                    TextField("Minty", text: $name)
                }
            }
        }
    }

    private func create() async throws {
        guard let repo = data.repo else { return }

        let id = try await repo.addTag(name: name)
        onCreated(id)
    }
}

struct NewTag_Previews: PreviewProvider {
    static var previews: some View {
        NewTag(onCreated: { _ in })
            .environmentObject(DataSource.preview)
    }
}

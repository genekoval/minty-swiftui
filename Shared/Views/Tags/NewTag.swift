import SwiftUI

struct NewTag: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var data: DataSource
    @Binding var id: String?
    @Binding var name: String

    var body: some View {
        VStack {
            HStack {
                Button("Cancel") { dismiss() }
                Spacer()
            }

            Spacer()

            Image(systemName: "tag")
                .font(.title)
                .padding()
            Text("New Tag")
                .bold()
                .font(.title)

            Spacer()

            Text("Enter a name for this tag.")
            TextField("Name", text: $name, onCommit: { create() })
                .disableAutocorrection(true)
                .submitLabel(.done)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Spacer()

            Button("Create") { create() }
                .buttonBorderShape(.capsule)
                .buttonStyle(.bordered)
                .controlSize(.large)
                .tint(.green)
        }
        .padding()
    }

    private func create() {
        guard let repo = data.repo else { return }

        do {
            id = try repo.addTag(name: name)
            dismiss()
        }
        catch {
            fatalError("Failed to create tag:\n\(error)")
        }
    }

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct NewTag_Previews: PreviewProvider {
    static var previews: some View {
        NewTag(id: .constant(""), name: .constant(""))
            .environmentObject(DataSource.preview)
    }
}

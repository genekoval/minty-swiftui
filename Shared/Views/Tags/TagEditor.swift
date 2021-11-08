import Combine
import SwiftUI

struct TagEditor: View {
    @State private var showingDeleteAlert = false

    @Binding var isPresented: Bool
    @ObservedObject var tag: TagViewModel

    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        TextField("Name", text: $tag.draftName)
                            .onSubmit { tag.commitName() }
                            .submitLabel(.done)
                    }

                    if tag.draftName != tag.name {
                        Button(action: { tag.draftName = tag.name }) {
                            HStack {
                                Image(systemName: "arrow.uturn.backward")
                                Text("Undo")
                            }
                        }

                        if tag.draftNameValid {
                            Button(action: { tag.commitName() }) {
                                HStack {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text("Save")
                                }
                            }
                        }
                    }
                }

                Section(header: Text("Aliases")) {
                    ForEach(tag.aliases, id: \.self) { alias in
                        HStack {
                            Text(alias)
                            Spacer()
                            Button(action: { tag.swap(alias: alias) }) {
                                Image(systemName: "rectangle.2.swap")
                            }
                        }
                    }
                    .onDelete {
                        if let index = $0.first {
                            tag.deleteAlias(at: index)
                        }
                    }

                    HStack {
                        if tag.draftAliasValid {
                            Button(action: { tag.addAlias() }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        else {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.secondary)
                        }

                        TextField("Add alias", text: $tag.draftAlias)
                            .onSubmit { tag.addAlias() }
                            .submitLabel(.done)
                    }
                }

                EditorLink(
                    title: "Description",
                    onSave: { tag.commitDescription() },
                    draft: $tag.draftDescription,
                    original: tag.description
                )

                Section(header: Text("Links")) {
                    ForEach(tag.sources) { SourceLink(source: $0) }
                        .onDelete {
                            if let index = $0.first {
                                tag.deleteSource(at: index)
                            }
                        }

                    HStack {
                        if tag.draftSourceValid {
                            Button(action: { tag.addSource() }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        else {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.secondary)
                        }

                        TextField("Add link", text: $tag.draftSource)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onSubmit { tag.addSource() }
                            .submitLabel(.done)
                    }
                }

                Section {
                    Button("Delete Tag", role: .destructive) {
                        showingDeleteAlert.toggle()
                    }
                }
            }
            .alert(
                Text("Delete this tag?"),
                isPresented: $showingDeleteAlert
            ) {
                Button("Delete", role: .destructive) { delete() }
            } message: { Text("This action cannot be undone.") }
            .navigationTitle("Edit Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(action: { isPresented.toggle() }) {
                    Text("Done")
                        .bold()
                }
            }
        }
    }

    private func delete() {
        tag.delete()
        isPresented.toggle()
    }
}

struct TagEditor_Previews: PreviewProvider {
    private static let deleted = Deleted()
    @StateObject private static var tag = TagViewModel.preview(
        id: "1",
        deleted: deleted
    )

    static var previews: some View {
        TagEditor(isPresented: .constant(true), tag: tag)
            .environmentObject(ObjectSource.preview)
    }
}

import Combine
import SwiftUI

struct TagEditor: View {
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var errorHandler: ErrorHandler

    @ObservedObject var tag: TagViewModel

    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        TextField("Name", text: $tag.draftName)
                            .onSubmit {
                                errorHandler.handle { try tag.commitName() }

                            }
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
                            Button(action: {
                                errorHandler.handle {
                                    try tag.commitName()
                                }
                            }) {
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
                            Button(action: {
                                errorHandler.handle {
                                    try tag.swap(alias: alias)
                                }
                            }) {
                                Image(systemName: "rectangle.2.swap")
                            }
                        }
                    }
                    .onDelete {
                        if let index = $0.first {
                            errorHandler.handle {
                                try tag.deleteAlias(at: index)
                            }
                        }
                    }

                    HStack {
                        if tag.draftAliasValid {
                            Button(action: {
                                errorHandler.handle { try tag.addAlias() }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        else {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.secondary)
                        }

                        TextField("Add alias", text: $tag.draftAlias)
                            .onSubmit {
                                errorHandler.handle { try tag.addAlias() }
                            }
                            .submitLabel(.done)
                    }
                }

                EditorLink(
                    title: "Description",
                    onSave: {
                        errorHandler.handle { try tag.commitDescription() }
                    },
                    draft: $tag.draftDescription,
                    original: tag.description
                )

                Section(header: Text("Links")) {
                    ForEach(tag.sources) { SourceLink(source: $0) }
                        .onDelete {
                            if let index = $0.first {
                                errorHandler.handle {
                                    try tag.deleteSource(at: index)
                                }
                            }
                        }

                    HStack {
                        if tag.draftSourceValid {
                            Button(action: {
                                errorHandler.handle { try tag.addSource() }
                            }) {
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
                            .onSubmit {
                                errorHandler.handle { try tag.addSource() }
                            }
                            .submitLabel(.done)
                    }
                }

                DeleteButton(for: "Tag") { delete() }
            }
            .navigationTitle("Edit Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(action: { dismiss() }) {
                    Text("Done")
                        .bold()
                }
            }
        }
    }

    private func delete() {
        errorHandler.handle {
            try tag.delete()
            dismiss()
        }
    }
}

struct TagEditor_Previews: PreviewProvider {
    @StateObject private static var tag = TagViewModel.preview(id: "1")

    static var previews: some View {
        TagEditor(tag: tag)
            .environmentObject(ObjectSource.preview)
    }
}

import Combine
import SwiftUI

struct TagEditor: View {
    @EnvironmentObject var errorHandler: ErrorHandler

    @ObservedObject var tag: TagViewModel

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $tag.draftName)
                    .onSubmit {
                        errorHandler.handle {
                            try await tag.commitName()
                        }
                    }
                    .submitLabel(.done)

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
                                try await tag.commitName()
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
                                try await tag.swap(alias: alias)
                            }
                        }) {
                            Image(systemName: "rectangle.2.swap")
                        }
                    }
                }
                .onDelete {
                    if let index = $0.first {
                        errorHandler.handle {
                            try await tag.deleteAlias(at: index)
                        }
                    }
                }

                HStack {
                    if tag.draftAliasValid {
                        Button(action: {
                            errorHandler.handle { try await tag.addAlias() }
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
                            errorHandler.handle { try await tag.addAlias() }
                        }
                        .submitLabel(.done)
                }
            }

            DraftEditorLink(
                title: "Description",
                original: tag.description,
                onSave: {
                    errorHandler.handle {
                        try await tag.commitDescription()
                    }
                },
                draft: $tag.draftDescription
            )

            Section(header: Text("Links")) {
                ForEach(tag.sources) { SourceLink(source: $0) }
                    .onDelete {
                        if let index = $0.first {
                            errorHandler.handle {
                                try await tag.deleteSource(at: index)
                            }
                        }
                    }

                HStack {
                    if tag.draftSourceValid {
                        Button(action: {
                            errorHandler.handle {
                                try await tag.addSource()

                            }
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
                            errorHandler.handle {
                                try await tag.addSource()
                            }
                        }
                        .submitLabel(.done)
                }
            }

            Section {
                DeleteButton(for: "Tag", action: delete)
            }
        }
        .playerSpacing()
    }

    private func delete() {
        errorHandler.handle {
            try await tag.delete()
        }
    }
}

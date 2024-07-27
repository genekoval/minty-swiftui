import SwiftUI

struct UserEditor: View {
    private enum Field {
        case name
        case alias
        case description
        case link
    }

    @EnvironmentObject private var data: DataSource
    @EnvironmentObject private var errorHandler: ErrorHandler

    @ObservedObject var user: User

    @FocusState private var focus: Field?

    var body: some View {
        List {
            Section {
                HStack {
                    TextField("Display Name", text: $user.draftName)
                        .focused($focus, equals: .name)
                        .submitLabel(.done)
                        .onSubmit(setName)

                    if focus == .name && !user.draftName.isEmpty {
                        Button(action: { user.draftName.removeAll() }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            Section {
                ForEach(user.aliases, id: \.self) { alias in
                    Text(alias)
                }
                .onDelete {
                    if let index = $0.first {
                        let alias = user.aliases[index]

                        errorHandler.handle {
                            user.load(names: try await data
                                .repo!
                                .deleteUserAlias(alias)
                            )
                        }
                    }
                }

                Button(action: addAlias, label: {
                    Label {
                        HStack {
                            TextField("Add alias", text: $user.draftAlias)
                                .focused($focus, equals: .alias)
                                .submitLabel(.done)
                                .onSubmit(addAlias)

                            if focus == .alias && !user.draftAlias.isEmpty {
                                Button(
                                    action: { user.draftAlias.removeAll() }
                                ) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    } icon: {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.multicolor)
                    }
                })
                .padding(.leading, -3)
            }

            Section {
                TextField(
                    "Description",
                    text: $user.draftDescription,
                    axis: .vertical
                )
                .focused($focus, equals: .description)
            }

            Section {
                ForEach(user.sources) { source in
                    Text(source.url.absoluteString)
                }
                .onDelete {
                    if let index = $0.first {
                        let id = user.sources[index].id

                        errorHandler.handle {
                            try await data.repo!.deleteUserSource(id: id)
                            user.sources.remove(id: id)
                        }
                    }
                }

                Button(action: addSource, label: {
                    Label {
                        HStack {
                            TextField("Add link", text: $user.draftSource)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .focused($focus, equals: .link)
                                .submitLabel(.done)
                                .onSubmit(addSource)

                            if focus == .link && !user.draftSource.isEmpty {
                                Button(
                                    action: { user.draftSource.removeAll()}
                                ) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    } icon: {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.multicolor)
                    }
                })
                .padding(.leading, -3)
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button("Cancel") { focus = nil }
                Spacer()
                Button(action: {
                    if let focus {
                        switch focus {
                        case .name: setName()
                        case .alias: addAlias()
                        case .description: setDescription()
                        case .link: addSource()
                        }

                        self.focus = nil
                    }
                }) {
                    Text("Done")
                        .bold()
                }
            }
        }
    }

    private func addAlias() {
        guard let alias = user.draftAlias.trimmed else { return }

        errorHandler.handle {
            let names = try await data.repo!.addUserAlias(alias)

            withAnimation {
                user.load(names: names)
            }

            user.draftAlias.removeAll()
        }
    }

    private func addSource() {
        guard let url = URL(string: user.draftSource) else { return }

        errorHandler.handle {
            let source = try await data.repo!.addUserSource(url)

            withAnimation {
                user.sources.append(source)
            }

            user.draftSource.removeAll()
        }
    }

    private func setDescription() {
        guard let description = user.draftDescription.trimmed else { return }

        errorHandler.handle {
            user.description = 
                try await data.repo!.setUserDescription(description)
        }
    }

    private func setName() {
        guard let name = user.draftName.trimmed else { return }

        errorHandler.handle {
            let names = try await data.repo!.setUserName(name)
            user.load(names: names)
        }
    }
}

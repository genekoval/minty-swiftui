import Minty
import SwiftUI

struct TagHome: View {
    @Environment(\.isSearching) var isSearching

    @EnvironmentObject var data: DataSource
    @EnvironmentObject var errorHandler: ErrorHandler

    @ObservedObject var query: TagQueryViewModel

    @State private var newTag: Tag.ID?
    @State private var showingTag = false

    var body: some View {
        PaddedScrollView {
            if isSearching {
                VStack {
                    if !query.name.isEmpty {
                        addButton
                            .padding([.horizontal, .top])
                    }

                    TagSearchResults(search: query)
                        .onReceive(query.$name) { _ in
                            if newTag != nil {
                                newTag = nil
                                showingTag = false
                            }
                        }
                }
            }
            else {
                EmptyView()
            }
        }
    }

    private var addButton: some View {
        HStack {
            if let id = newTag {
                let tag = data.state.tags.fetch(id: id)

                NavigationLink(destination: TagDetail(tag: tag)) {
                    HStack {
                        Image(systemName: "tag")
                        Text(name)
                    }
                }
                .navigationDestination(isPresented: $showingTag) {
                    TagDetail(tag: tag)
                }
            }
            else {
                Button(action: addTag) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Tag")
                    }
                }
            }

            Spacer()
        }
        .buttonStyle(.automatic)
    }

    private var name: String {
        query.name.trimmingCharacters(in: .whitespaces)
    }

    private func addTag() {
        guard let repo = data.repo else { return }

        errorHandler.handle {
            newTag = try await repo.addTag(name: name)
            showingTag = true
        }
    }
}

struct TagHome_Previews: PreviewProvider {
    @StateObject private static var query = TagQueryViewModel.preview()

    static var previews: some View {
        TagHome(query: query)
    }
}

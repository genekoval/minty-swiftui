import Combine
import SwiftUI

struct NewTagButton: View {
    @EnvironmentObject private var data: DataSource
    @EnvironmentObject private var errorHandler: ErrorHandler

    let name: String

    @Binding var tag: TagViewModel?

    @State private var cancellable: AnyCancellable?
    @State private var creating = false
    @State private var showingTag = false

    var body: some View {
        HStack {
            if let tag {
                NavigationLink(destination: TagHost(tag: tag)) {
                    Label(name, systemImage: "tag")
                }
                .navigationDestination(isPresented: $showingTag) {
                    TagHost(tag: tag)
                }
            }
            else {
                Button(action: createTag) {
                    Label {
                        Text("Create Tag")
                    } icon: {
                        if creating {
                            ProgressView()
                        }
                        else {
                            Image(systemName: "plus")
                        }
                    }
                }
                .disabled(creating)
            }
        }
        .buttonStyle(.automatic)
    }

    private func createTag() {
        guard let repo = data.repo else { return }

        creating = true

        errorHandler.handle {
            let id = try await repo.addTag(name: name)

            let tag = data.state.tags.fetch(id: id)

            cancellable = tag.$deleted.sink { deleted in
                if deleted {
                    self.tag = nil
                }
            }

            self.tag = tag
            creating = false
            showingTag = true
        } dismissAction: {
            creating = false
        }
    }
}

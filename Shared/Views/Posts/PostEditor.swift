import SwiftUI

struct PostEditor: View {
    private enum Field {
        case title
        case description
    }

    @Environment(\.postControlsHidden) private var postControlsHidden

    @EnvironmentObject private var errorHandler: ErrorHandler

    @ObservedObject var post: PostViewModel

    @State private var descriptionPresented = false

    @FocusState private var focus: Field?

    var body: some View {
        PaddedScrollView {
            VStack(alignment: .leading, spacing: 10) {
                TextField("Title", text: $post.draftTitle, axis: .vertical)
                    .bold()
                    .font(.title2)
                    .focused($focus, equals: .title)
                    .submitLabel(.done)
                    .disabled(focus == nil && postControlsHidden.wrappedValue)
                    .onChange(of: post.draftTitle) {
                        if post.draftTitle.contains("\n") {
                            focus = nil
                            post.draftTitle = post
                                .draftTitle
                                .replacingOccurrences(of: "\n", with: "")
                            submitText()
                        }
                    }

                TextField(
                    "Description",
                    text: $post.draftDescription,
                    axis: .vertical
                )
                .focused($focus, equals: .description)
                .disabled(focus == nil && postControlsHidden.wrappedValue)
            }
            .padding()

            ObjectEditorButton(post: post)
                .disabled(focus != nil)

            RelatedPostsEditorButton(post: post)
                .disabled(postControlsHidden.wrappedValue)

            PostTagEditorButton(post: post)
                .disabled(postControlsHidden.wrappedValue)
        }
        .postControlsHdden(focus != nil)
        .toolbar {
            if focus != nil {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: submitText) {
                        Text("Done")
                            .bold()
                    }
                }
            }

            ToolbarItemGroup(placement: .keyboard) {
                Button("Cancel") { focus = nil }
                Spacer()
                Button("Reset") { 
                    post.draftTitle = post.title
                    post.draftDescription = post.description
                    focus = nil
                }
                .disabled(!textModified)
            }
        }
    }

    private var textModified: Bool {
        post.draftTitle != post.title ||
        post.draftDescription != post.description
    }

    private func delete() {
        errorHandler.handle {
            try await post.delete()
        }
    }

    private func submitText() {
        errorHandler.handle {
            try await post.commitTitle()
            try await post.commitDescription()
            focus = nil
        }
    }
}

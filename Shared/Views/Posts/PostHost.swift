import SwiftUI

private struct ControlsKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

extension EnvironmentValues {
    var postControlsHidden: Binding<Bool> {
        get { self[ControlsKey.self] }
        set { self[ControlsKey.self] = newValue }
    }
}

private struct ControlsHidden: ViewModifier {
    @Environment(\.postControlsHidden) private var postControlsHidden

    let hidden: Bool

    func body(content: Content) -> some View {
        content
            .onChange(of: hidden) {
                postControlsHidden.wrappedValue = hidden
            }
    }
}

extension View {
    func postControlsHdden(_ hidden: Bool) -> some View {
        modifier(ControlsHidden(hidden: hidden))
    }
}

struct PostHost: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var data: DataSource
    @EnvironmentObject private var errorHandler: ErrorHandler

    @ObservedObject var post: PostViewModel

    @State private var controlsHidden = false

    var body: some View {
        content
            .loadEntity(post)
            .environment(\.postControlsHidden, $controlsHidden)
            .navigationTitle(post.visibility == .draft ? "Draft" : "Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if canEdit && !controlsHidden {
                    edit
                    delete
                    if post.visibility == .draft { publish }
                }
            }
            .onAppear { if post.deleted { dismiss() }}
            .onReceive(post.$deleted) { if $0 { dismiss() }}
    }

    private var canEdit: Bool {
        isPoster || data.isAdmin
    }

    @ViewBuilder
    private var content: some View {
        if post.isEditing {
            PostEditor(post: post)
        }
        else {
            PostDetail(post: post)
        }
    }

    @ViewBuilder
    private var delete: some View {
        DeleteButton(
            for: post.visibility == .draft ? "Draft" : "Post",
            action: {
                errorHandler.handle {
                    try await post.delete()
                }
            }
        )
    }

    @ViewBuilder
    private var edit: some View {
        Button(action: {
            withAnimation {
                post.isEditing.toggle()
            }
        }) {
            Image(systemName: "pencil.circle")
                .symbolVariant(post.isEditing ? .fill : .none)
        }
    }

    private var isPoster: Bool {
        post.poster != nil && post.poster == data.user
    }

    @ViewBuilder
    private var publish: some View {
        Button(action: {
            errorHandler.handle {
                try await post.createPost()
            }
        }) {
            Image(systemName: "paperplane")
        }
    }
}

/*
struct PostHost_Previews: PreviewProvider {
    private static let tag = TagViewModel.preview(id: PreviewTag.empty)

    static var previews: some View {
        NavigationView {
            PostHost(post: $tag.draftPost)
        }
        .withErrorHandling()
        .environmentObject(DataSource.preview)
        .environmentObject(ObjectSource.preview)
        .environmentObject(Overlay())
    }
}
*/

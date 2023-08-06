import Combine
import SwiftUI

struct TagHost: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var tag: TagViewModel

    @State private var cancellable: AnyCancellable?

    var body: some View {
        content
            .loadEntity(tag)
            .navigationTitle(tag.isEditing ? "Edit Tag" : tag.name)
            .navigationBarTitleDisplayMode(tag.isEditing ? .inline : .large)
            .toolbar { edit }
            .onAppear { if tag.deleted { dismiss() }}
            .onReceive(tag.$deleted) { if $0 { dismiss() }}
    }

    @ViewBuilder
    private var content: some View {
        if tag.isEditing {
            TagEditor(tag: tag)
        }
        else {
            TagDetail(tag: tag)
        }
    }

    @ViewBuilder
    private var edit: some View {
        Button(action: { tag.isEditing.toggle() }) {
            if tag.isEditing {
                Text("Done")
                    .bold()
            }
            else {
                Text("Edit")
            }
        }
    }
}

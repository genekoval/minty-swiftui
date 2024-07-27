import Combine
import SwiftUI

struct TagHost: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject private var data: DataSource

    @ObservedObject var tag: TagViewModel

    @State private var cancellable: AnyCancellable?

    var body: some View {
        content
            .loadEntity(tag)
            .navigationTitle(tag.isEditing ? "Edit Tag" : tag.name)
            .navigationBarTitleDisplayMode(tag.isEditing ? .inline : .large)
            .toolbar {
                if canEdit {
                    edit
                }
            }
            .onAppear { if tag.deleted { dismiss() }}
            .onReceive(tag.$deleted) { if $0 { dismiss() }}
    }

    private var canEdit: Bool {
        isCreator || data.isAdmin
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

    private var isCreator: Bool {
        tag.creator != nil && tag.creator == data.user
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

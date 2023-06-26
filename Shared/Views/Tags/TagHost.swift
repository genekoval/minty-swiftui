import Combine
import SwiftUI

struct TagHost: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var tag: TagViewModel

    @StateObject private var recentPosts: PostQueryViewModel
    @StateObject private var search: PostQueryViewModel

    @State private var cancellable: AnyCancellable?

    var body: some View {
        content
            .loadEntity(tag)
            .prepareSearch(recentPosts)
            .prepareSearch(search)
            .navigationTitle(tag.isEditing ? "Edit Tag" : tag.name)
            .navigationBarTitleDisplayMode(tag.isEditing ? .inline : .large)
            .toolbar { edit }
            .onAppear { if tag.deleted { dismiss() }}
            .onReceive(tag.$deleted) { if $0 { dismiss() }}
            .onReceive(tag.$draftPost) {
                if let draft = $0 {
                    cancellable = draft.$visibility.sink { [weak recentPosts] in
                        if $0 != .draft {
                            Task {
                                await recentPosts?.newSearch()
                            }
                        }
                    }
                }
                else {
                    cancellable = nil
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        if tag.isEditing {
            TagEditor(tag: tag)
        }
        else {
            TagDetail(tag: tag, recentPosts: recentPosts, search: search)
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

    init(tag: TagViewModel) {
        self.tag = tag
        _recentPosts = StateObject(wrappedValue: PostQueryViewModel(
            tag: tag,
            searchNow: true
        ))
        _search = StateObject(wrappedValue: PostQueryViewModel(tag: tag))
    }
}

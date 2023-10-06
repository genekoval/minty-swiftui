typealias CommentState = StateMap<CommentViewModel>
typealias PostState = StateMap<PostViewModel>
typealias TagState = StateMap<TagViewModel>

struct AppState {
    let comments = EntityStore<CommentViewModel>()
    let posts = EntityStore<PostViewModel>()
    let tags = EntityStore<TagViewModel>()
}

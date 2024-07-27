typealias CommentState = StateMap<CommentViewModel>
typealias PostState = StateMap<PostViewModel>
typealias TagState = StateMap<TagViewModel>
typealias UserState = StateMap<User>

struct AppState {
    let comments = EntityStore<CommentViewModel>()
    let posts = EntityStore<PostViewModel>()
    let tags = EntityStore<TagViewModel>()
    let users = EntityStore<User>()
}

typealias PostState = StateMap<PostViewModel>
typealias TagState = StateMap<TagViewModel>

struct AppState {
    let posts = EntityStore<PostViewModel>()
    let tags = EntityStore<TagViewModel>()
}

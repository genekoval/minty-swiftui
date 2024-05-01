import Combine
import Minty

class CurrentUser: ObservableObject {
    @Published var drafts: [PostViewModel] = []
    @Published var totalDrafts = 0

    private var cancellables = Set<AnyCancellable>()

    init() {
        Post
            .published
            .sink { [weak self] id in self?.removeDraft(id: id) }
            .store(in: &cancellables)

        Post
            .deleted
            .sink { [weak self] id in self?.removeDraft(id: id) }
            .store(in: &cancellables)
    }

    private func removeDraft(id: Post.ID) {
        if drafts.remove(id: id) != nil {
            totalDrafts -= 1
        }
    }
}

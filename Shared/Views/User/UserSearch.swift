import Minty
import SwiftUI

struct UserSearch: View {
    var body: some View {
        PaddedScrollView {

        }
        .navigationTitle("Users")
        .userSearch()
    }
}

private enum SearchState {
    case none
    case done
    case searching
    case error(String)
}

private struct UserSearchOverlay<Content>: View where Content : View {
    @Environment(\.isSearching) private var isSearching

    @EnvironmentObject private var data: DataSource

    @Binding var users: [User]
    @Binding var total: Int

    let name: String
    let state: SearchState
    let content: (User) -> Content

    var body: some View {
        if isSearching {
            ZStack {
                Rectangle()
                    .fill(.background)

                PaddedScrollView {
                    LazyVStack {
                        switch state {
                        case .none:
                            // Maybe show search history here
                            EmptyView()
                        case .done:
                            results
                        case .searching:
                            ProgressView { Text("Searching") }
                        case .error(let message):
                            NoResults(
                                heading: "Search Failed",
                                subheading: message
                            )
                        }
                    }
                    .padding()
                }
            }
        }
    }

    private var noResultsText: String {
        "There were no results for “\(name)”. Try a new search."
    }

    @ViewBuilder
    private var results: some View {
        if users.isEmpty {
            NoResults(subheading: noResultsText)
        } else {
            InfiniteScroll(
                users,
                stopIf: users.count == total,
                more: { [self] in try await self.loadMore() }
            ) {
                content($0)
                Divider()
            }
        }
    }

    private func loadMore() async throws {
        let result = try await data.findUsers(
            name.trimmingCharacters(in: .whitespaces),
            from: users.count,
            size: 100
        )

        users.append(contentsOf: result.hits)
        total = result.total
    }
}

private struct UserSearchModifier<UserView>: ViewModifier 
where UserView : View {
    @EnvironmentObject private var data: DataSource

    let userView: (User) -> UserView

    @State private var name = ""
    @State private var state: SearchState = .none
    @State private var users: [User] = []
    @State private var total = 0
    @State private var task: Task<Void, Never>?

    func body(content: Content) -> some View {
        ZStack {
            content
            UserSearchOverlay(
                users: $users,
                total: $total,
                name: name,
                state: state,
                content: userView
            )
        }
        .searchable(text: $name)
        .onChange(of: name, search)
        .onReceive(User.deleted, perform: removeUser)
        .onSubmit(of: .search, search)
    }

    private func removeUser(id: User.ID) {
        if users.remove(id: id) != nil {
            total -= 1
        }
    }

    private func reset() {
        if !users.isEmpty {
            users.removeAll()
            total = 0
        }

        state = .none
    }

    private func search() {
        task?.cancel()

        guard let name = name.trimmed else {
            reset()
            return
        }

        task = Task {
            let progress = Task.after(.milliseconds(50)) { state = .searching }
            defer { progress.cancel() }

            do {
                let result = try await data.findUsers(
                    name,
                    size: 50
                )

                users = result.hits
                total = result.total
                state = .done
            }
            catch {
                if !Task.isCancelled {
                    state = .error(error.localizedDescription)
                }
            }
        }
    }
}

struct UserRow: View {
    @ObservedObject var user: User

    var body: some View {
        NavigationLink(destination: UserHost(user: user)) {
            HStack {
                Text(user.name)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension View {
    func userSearch() -> some View {
        userSearch() {
            UserRow(user: $0)
        }
    }

    func userSearch<Content: View>(
        _ content: @escaping (User) -> Content
    ) -> some View {
        modifier(UserSearchModifier(userView: content))
    }
}

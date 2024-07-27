import SwiftUI

struct UserHost: View {
    @Environment(\.editMode) private var editMode

    @EnvironmentObject private var data: DataSource

    @ObservedObject var user: User

    var body: some View {
        content
            .loadEntity(user)
            .toolbar {
                if user == data.user {
                    EditButton()
                }
            }
            .onReceive(data.$user) { u in
                if u != self.user {
                    editMode?.wrappedValue = .inactive
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        if editMode?.wrappedValue.isEditing == true {
            UserEditor(user: user)
        } else {
            UserDetail(user: user)
        }
    }
}

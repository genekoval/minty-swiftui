import SwiftUI

private struct SearchLabel<Destination>: View where Destination : View {
    private let name: String
    private let icon: String
    private let color: Color
    private let destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            Label {
                Text(name)
            } icon: {
                Image(systemName: icon)
                    .symbolVariant(.fill)
                    .foregroundColor(color)
            }
        }
    }

    init(
        _ name: String,
        icon: String,
        color: Color,
        @ViewBuilder destination: () -> Destination
    ) {
        self.name = name
        self.icon = icon
        self.color = color
        self.destination = destination()
    }
}

struct SearchHome: View {
    var body: some View {
        NavigationStack {
            List {
                SearchLabel("Tags", icon: "tag", color: .green) {
                    TagHome()
                }

                SearchLabel("Posts", icon: "doc.text.image", color: .blue) {
                    PostHome()
                }
            }
            .listStyle(.plain)
            .navigationBarTitle("Search")
        }
    }
}

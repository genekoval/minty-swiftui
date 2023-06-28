import SwiftUI

private struct NoResultsTitle: EnvironmentKey {
    static let defaultValue = "No Results"
}

private struct NoResultsText: EnvironmentKey {
    static let defaultValue = "Try a new search."
}

extension EnvironmentValues {
    var noResultsTitle: String {
        get { self[NoResultsTitle.self] }
        set { self[NoResultsTitle.self] = newValue }
    }

    var noResultsText: String {
        get { self[NoResultsText.self] }
        set { self[NoResultsText.self] = newValue }
    }
}

private struct NoResultsTitleModifier: ViewModifier {
    let title: String

    func body(content: Content) -> some View {
        content
            .environment(\.noResultsTitle, title)
    }
}

private struct NoResultsTextModifier: ViewModifier {
    let text: String

    func body(content: Content) -> some View {
        content
            .environment(\.noResultsText, text)
    }
}

extension View {
    func noResultsTitle(_ title: String) -> some View {
        modifier(NoResultsTitleModifier(title: title))
    }

    func noResultsText(_ text: String) -> some View {
        modifier(NoResultsTextModifier(text: text))
    }
}

struct ResultCount<SideContent>: View where SideContent : View {
    @Environment(\.noResultsTitle) private var noResultsTitle
    @Environment(\.noResultsText) private var noResultsText

    private let typeSingular: String
    private let typePlural: String
    private let count: Int
    private let sideContent: SideContent

    var body: some View {
        if count > 0 {
            HStack {
                Text(countText)
                    .bold()
                    .font(.headline)

                Spacer()

                sideContent
            }
            .padding()
        }
        else {
            VStack(spacing: 10) {
                HStack {
                    Spacer()
                    sideContent
                }

                Spacer(minLength: 40)

                Text(noResultsTitle)
                    .bold()
                    .font(.title2)

                Text(noResultsText)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }

    private var countFormatted: String {
        NumberFormatter.localizedString(
            from: NSNumber(value: count),
            number: .decimal
        )
    }

    private var countText: String {
        "\(countFormatted) \(count == 1 ? typeSingular : typePlural)"
    }

    init(
        type: String,
        typePlural: String? = nil,
        count: Int
    ) where SideContent == EmptyView {
        self.init(
            type: type,
            typePlural: typePlural,
            count: count,
            sideContent: { EmptyView() }
        )
    }

    init(
        type: String,
        typePlural: String? = nil,
        count: Int,
        @ViewBuilder sideContent: () -> SideContent
    ) {
        typeSingular = type
        self.typePlural = typePlural ?? "\(type)s"
        self.count = count
        self.sideContent = sideContent()
    }
}

struct ResultCount_Previews: PreviewProvider {
    private static let type = "Item"

    static var previews: some View {
        Group {
            ResultCount(
                type: type,
                count: 0
            )

            ResultCount(
                type: type,
                count: 0
            )
            .noResultsTitle("No Drafts")
            .noResultsText("Drafts will appear here.")

            ResultCount(
                type: type,
                count: 1
            )

            ResultCount(
                type: type,
                count: 1_000
            )
        }
    }
}

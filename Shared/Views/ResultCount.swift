import SwiftUI

struct ResultCount: View {
    let typeSingular: String
    let typePlural: String

    @Binding var count: Int
    @Binding var text: String

    var body: some View {
        if count > 0 {
            HStack {
                Text(countText)
                    .bold()
                    .font(.headline)
                    .padding()
                Spacer()
            }
        }
        else {
            VStack(spacing: 10) {
                Spacer(minLength: 40)

                Text("No Results")
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

    private var noResultsText: String {
        "There were no results for \"\(text)\". Try a new search."
    }
}

struct ResultCount_Previews: PreviewProvider {
    private static let text: Binding<String> = .constant("hello")
    private static let typeSingular = "Item"
    private static let typePlural = "Items"

    static var previews: some View {
        Group {
            ResultCount(
                typeSingular: typeSingular,
                typePlural: typePlural,
                count: .constant(0),
                text: text
            )

            ResultCount(
                typeSingular: typeSingular,
                typePlural: typePlural,
                count: .constant(1),
                text: text
            )

            ResultCount(
                typeSingular: typeSingular,
                typePlural: typePlural,
                count: .constant(10_000),
                text: text
            )
        }
    }
}

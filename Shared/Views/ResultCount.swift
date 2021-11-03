import SwiftUI

struct ResultCount: View {
    let typeSingular: String
    let typePlural: String
    let count: Int
    let text: String?

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
        var message = "Try a new search."

        if let text = text {
            message = "There were no results for “\(text)”. \(message)"
        }

        return message
    }

    init(
        type: String,
        typePlural: String? = nil,
        count: Int,
        text: String? = nil
    ) {
        typeSingular = type
        self.typePlural = typePlural ?? "\(type)s"
        self.count = count
        self.text = text
    }
}

struct ResultCount_Previews: PreviewProvider {
    private static let text = "hello"
    private static let type = "Item"

    static var previews: some View {
        Group {
            ResultCount(
                type: type,
                count: 0,
                text: nil
            )
            .previewLayout(.fixed(width: 400, height: 200))

            ResultCount(
                type: type,
                count: 0,
                text: text
            )
            .previewLayout(.fixed(width: 400, height: 200))

            ResultCount(
                type: type,
                count: 1,
                text: text
            )

            ResultCount(
                type: type,
                count: 1_000,
                text: text
            )
        }
        .previewLayout(.sizeThatFits)
    }
}

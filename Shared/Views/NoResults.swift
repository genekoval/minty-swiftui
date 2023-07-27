import SwiftUI

struct NoResults: View {
    private let heading: String
    private let subheading: String

    var body: some View {
        VStack(spacing: 10) {
            Spacer(minLength: 40)

            Text(heading)
                .bold()
                .font(.title2)

            Text(subheading)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    init(
        heading: String = "No Results",
        subheading: String = "Try a new search."
    ) {
        self.heading = heading
        self.subheading = subheading
    }
}

struct NoResults_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            NoResults()
        }
    }
}

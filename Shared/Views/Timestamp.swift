import SwiftUI

struct Timestamp: View {
    let prefix: String
    let systemImage: String
    var date: Date

    var body: some View {
        HStack {
            Image(systemName: systemImage)

            VStack(alignment: .leading) {
                Text("\(prefix) **\(date.relative(.full))**")
                Text(date.string)
            }

            Spacer()
        }
        .font(.caption)
        .foregroundColor(.secondary)
    }
}

struct Timestamp_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Timestamp(
                prefix: "Created",
                systemImage: "calendar",
                date: Date(from: "2000-01-01 00:00:00.000-04")
            )

            Timestamp(
                prefix: "Posted",
                systemImage: "clock",
                date: Date() - (60 * 60)
            )

            Timestamp(
                prefix: "Last updated",
                systemImage: "pencil",
                date: Date()
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

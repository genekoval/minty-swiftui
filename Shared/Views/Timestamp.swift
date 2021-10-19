import SwiftUI

struct Timestamp: View {
    let prefix: String
    let systemImage: String
    @Binding var date: Date

    var body: some View {
        HStack {
            Image(systemName: systemImage)

            VStack(alignment: .leading) {
                HStack {
                    Text(prefix)
                    Text(date.relative)
                        .bold()
                }

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
        Timestamp(
            prefix: "Created",
            systemImage: "calendar",
            date: .constant(Date(from: "2000-01-01 00:00:00.000-04"))
        )
    }
}

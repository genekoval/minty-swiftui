import SwiftUI

struct CacheRow: View {
    let object: ObjectFile

    var body: some View {
        VStack {
            HStack {
                Text(object.id)
                    .font(.system(.footnote, design: .monospaced))
                Spacer()
            }

            HStack {
                Text(object.size.asByteCount)
                Spacer()
            }
            .foregroundColor(.secondary)
            .padding(.top, 1)
        }
    }
}

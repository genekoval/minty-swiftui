import SwiftUI

struct TagDetail: View {
    @EnvironmentObject var data: DataSource
    @StateObject private var tag = TagViewModel()

    let id: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(tag.name)
                        .bold()
                        .font(.title)
                    Spacer()
                }

                if !tag.aliases.isEmpty {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(tag.aliases, id: \.self) { alias in
                            Text(alias)
                                .bold()
                                .font(.footnote)
                        }
                    }
                    .padding(.leading, 10)
                }

                if let description = tag.description {
                    Text(description)
                }

                if !tag.sources.isEmpty {
                    ForEach(tag.sources) { source in
                        SourceLink(source: source)
                    }
                }

                Timestamp(
                    prefix: "Created",
                    systemImage: "calendar",
                    date: $tag.dateCreated
                )

                HStack {
                    Image(systemName: "doc.text.image")

                    Text(
                        "\(tag.postCount) Post\(tag.postCount == 1 ? "" : "s")"
                    )
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle(tag.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { load() }
    }

    private func load() {
        tag.id = id
        tag.repo = data.repo
    }
}

struct TagDetail_Previews: PreviewProvider {
    static var previews: some View {
        TagDetail(id: "1")
            .environmentObject(DataSource.preview)
    }
}

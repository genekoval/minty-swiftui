import Minty
import SwiftUI

struct TagDetail: View {
    @Environment(\.dismiss) var dismiss

    @ObservedObject var deleted: Deleted

    @StateObject private var tag: TagViewModel

    @State private var showingEditor = false

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
                    date: tag.dateCreated
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
        .onReceive(deleted.$id) { id in
            if let id = id {
                if id == tag.id {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingEditor) { TagEditor(tag: tag) }
        .toolbar {
            Button("Edit") {
                showingEditor.toggle()
            }
        }
    }

    init(id: String, repo: MintyRepo?, deleted: Deleted) {
        self.deleted = deleted
        _tag = StateObject(
            wrappedValue: TagViewModel(id: id, repo: repo, deleted: deleted)
        )
    }
}

struct TagDetail_Previews: PreviewProvider {
    @StateObject private static var deleted = Deleted()

    static var previews: some View {
        NavigationView {
            TagDetail(id: "1", repo: PreviewRepo(), deleted: deleted)
        }
        .environmentObject(DataSource.preview)
        .environmentObject(ObjectSource.preview)
    }
}

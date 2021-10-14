import Minty
import SwiftUI

struct TagSearch: View {
    @EnvironmentObject var app: AppState
    @StateObject private var query = TagQueryViewModel()

    var body: some View {
        ScrollView {
            LazyVStack {
                if searching {
                    if query.total > 0 {
                        HStack {
                            Text(total)
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

                ForEach($query.hits) { tag in
                    NavigationLink(
                        destination: TagDetail(id: tag.id.wrappedValue)
                    ) {
                        VStack {
                            TagRow(tag: tag.wrappedValue)
                            Divider()
                        }
                        .padding(.horizontal)
                    }
                }

                if query.resultsAvailable {
                    ProgressView()
                        .onAppear { query.nextPage() }
                        .progressViewStyle(.circular)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .navigationTitle("Tags")
        .onAppear { query.repo = app.repo }
        .searchable(text: $query.name)
    }

    private var noResultsText: String {
        "There were no results for \"\(query.name)\". Try a new search."
    }

    private var searching: Bool { !query.name.isEmpty }

    private var total: String {
        "\(query.total) Tag\(query.total == 1 ? "" : "s")"
    }
}

struct TagSearch_Previews: PreviewProvider {
    static var previews: some View {
        TagSearch()
            .environmentObject(AppState())
    }
}

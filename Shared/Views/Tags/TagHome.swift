import Minty
import SwiftUI

struct TagHome: View {
    @State private var newTags: [TagViewModel] = []

    var body: some View {
        PaddedScrollView {
            if !newTags.isEmpty {
                VStack(alignment: .leading) {
                    Text("Recently Added")
                        .font(.title2)
                        .bold()
                        .padding(.bottom)

                    TagList(tags: $newTags)
                }
                .padding()
            }
            else {
                EmptyView()
            }
        }
        .navigationTitle("Tags")
        .toolbar {
            NewTagButton { tag in
                withAnimation {
                    newTags.insert(tag, at: 0)
                }
            }
        }
        .tagSearch()
    }
}

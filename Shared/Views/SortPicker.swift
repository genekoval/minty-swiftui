import Minty
import SwiftUI

struct SortPicker: View {
    @Binding var sort: PostQuery.Sort

    var body: some View {
        Menu {
            ForEach(PostQuery.Sort.SortValue.allCases) { value in
                Button(action: {
                    if sort.value == value {
                        sort.order.toggle()
                    }
                    else {
                        sort = PostQuery.Sort(by: value)
                    }
                }) {
                    if sort.value == value {
                        Label(
                            value.rawValue.capitalized,
                            systemImage: sort.order == .ascending ?
                                "chevron.up" : "chevron.down"
                        )
                    }
                    else {
                        Text(value.rawValue.capitalized)
                    }
                }
            }
        } label: {
            Label("Sort", systemImage: "arrow.up.and.down.text.horizontal")
        }
    }
}

struct SortPicker_Previews: PreviewProvider {
    private struct Preview: View {
        @State private var sort: PostQuery.Sort = .created

        var body: some View {
            SortPicker(sort: $sort)
        }
    }

    static var previews: some View {
        Preview()
    }
}

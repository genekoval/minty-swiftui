import SwiftUI

// The spacing between individual items in the grid.
private let spacing: CGFloat = 2

struct Grid<Content>: View where Content : View {
    let content: Content

    private var columns: [GridItem] = Array(
        repeating: .init(.flexible(), spacing: spacing),
        count: 3
    )

    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            content
                .aspectRatio(1, contentMode: .fit)
        }
    }

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
}

struct Grid_Previews: PreviewProvider {
    static var previews: some View {
        Grid {
            ForEach(1..<10) {
                Text("\($0)")
                    .font(.system(.title, design: .monospaced))
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .border(.black)
        }
    }
}

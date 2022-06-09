import Minty
import SwiftUI

struct OverlayNavigationBar: View {
    @EnvironmentObject var overlay: Overlay

    var body: some View {
        // Use a VStack with a spacer to push the navigation bar to the top of
        // the screen.
        VStack {
            navigationBar
            Spacer()
        }
    }

    @ViewBuilder
    private var cancellationAction: some View {
        closeButton
    }

    @ViewBuilder
    private var closeButton: some View {
        Button(action: close) {
            Text("Done")
                .bold()
        }
    }

    @ViewBuilder
    private var infoButton: some View {
        Button(action: { overlay.info() }) {
            Image(systemName: "info.circle")
                .font(.title2)
        }
    }

    @ViewBuilder
    private var navigationBar: some View {
        // Use a ZStack here to keep the title centered regardless of the items
        // to the right and left of it.
        ZStack {
            title

            HStack {
                cancellationAction
                Spacer()
                primaryAction
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private var primaryAction: some View {
        if overlay.infoEnabled {
            infoButton
        }
    }

    @ViewBuilder
    private var title: some View {
        Text(overlay.title)
            .bold()
    }

    private func close() {
        overlay.hide()
    }
}

struct OverlayNavigationBar_Previews: PreviewProvider {
    private struct Preview: View {
        private let post = PostViewModel.preview(id: PreviewPost.sandDune)

        @StateObject private var overlay = Overlay()

        var body: some View {
            OverlayNavigationBar()
                .environmentObject(overlay)
                .onAppear { overlay.load(provider: post) }
        }
    }

    static var previews: some View {
        Preview()
    }
}

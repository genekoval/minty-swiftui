import Combine
import Minty
import SwiftUI

final class Overlay: ObservableObject {
    @Published var index: Int = 0
    @Published var opacity: Double = 1.0
    @Published var uiVisible = true

    @Published private(set) var objects: [ObjectPreview] = []
    @Published private(set) var visible = false

    private var infoPresented: Binding<String?>?

    var infoEnabled: Bool {
        infoPresented != nil
    }

    var title: String {
        "\(index + 1) of \(objects.count)"
    }

    func hide() {
        visible = false
        uiVisible = true
    }

    func info() {
        if let selection = infoPresented {
            selection.wrappedValue = objects[index].id
            hide()
        }
    }

    func load(
        objects: [ObjectPreview],
        infoPresented: Binding<String?>? = nil
    ) {
        self.objects = objects
        self.infoPresented = infoPresented
    }

    func show(object: ObjectPreview) {
        guard let index = objects.firstIndex(of: object) else { return }
        self.index = index
        visible = true
    }
}

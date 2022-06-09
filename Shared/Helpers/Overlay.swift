import Combine
import Foundation
import Minty
import SwiftUI

protocol ObjectProvider {
    var id: UUID { get }

    var objects: [ObjectPreview] { get }

    var objectsPublisher: Published<[ObjectPreview]>.Publisher { get }
}

final class Overlay: ObservableObject {
    @Published var index: Int = 0
    @Published var opacity: Double = 1.0
    @Published var uiVisible = true

    @Published private(set) var objects: [ObjectPreview] = []
    @Published private(set) var visible = false

    private var cancellable: AnyCancellable?
    private var infoPresented: Binding<UUID?>?
    private var providerId: UUID?

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
        provider: ObjectProvider,
        infoPresented: Binding<UUID?>? = nil
    ) {
        guard providerId != provider.id else { return }

        providerId = provider.id
        cancellable = provider.objectsPublisher.sink { [weak self] in
            guard let self = self else { return }
            self.objects = $0.filter { $0.isViewable }
        }

        self.infoPresented = infoPresented
    }

    func show(object: ObjectPreview) {
        guard let index = objects.firstIndex(of: object) else { return }
        self.index = index
        visible = true
    }
}

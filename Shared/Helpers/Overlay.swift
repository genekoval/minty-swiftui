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
    private var providerId: UUID?

    var title: String {
        "\(index + 1) of \(objects.count)"
    }

    func hide() {
        visible = false
        uiVisible = true
    }

    func load(provider: ObjectProvider) {
        guard providerId != provider.id else { return }

        providerId = provider.id
        cancellable = provider.objectsPublisher.sink { [weak self] in
            self?.objects = $0.filter { $0.isViewable }
        }
    }

    func show(object: ObjectPreview) {
        guard let index = objects.firstIndex(of: object) else { return }
        self.index = index
        visible = true
    }
}

import SwiftUI

private struct LoadEntity: ViewModifier {
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var data: DataSource
    @EnvironmentObject var errorHandler: ErrorHandler

    let entity: RemoteEntity

    @State private var loaded = false

    func body(content: Content) -> some View {
        content
            .onAppear {
                errorHandler.handle {
                    try load()
                } dismissAction: {
                    dismiss()
                }
            }
    }

    private func load() throws {
        if !loaded {
            try entity.load(repo: data.repo)
            loaded = true
        }
    }
}

extension View {
    func loadEntity(_ entity: RemoteEntity) -> some View {
        modifier(LoadEntity(entity: entity))
    }
}

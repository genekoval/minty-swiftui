import SwiftUI

private struct LoadEntity: ViewModifier {
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var data: DataSource
    @EnvironmentObject var errorHandler: ErrorHandler

    let entity: RemoteEntity

    func body(content: Content) -> some View {
        content
            .onFirstAppearance {
                errorHandler.handle {
                    try entity.load(app: data)
                } dismissAction: {
                    dismiss()
                }
            }
    }
}

extension View {
    func loadEntity(_ entity: RemoteEntity) -> some View {
        modifier(LoadEntity(entity: entity))
    }
}

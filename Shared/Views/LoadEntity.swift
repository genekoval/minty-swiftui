import SwiftUI

private struct LoadEntity: ViewModifier {
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var data: DataSource
    @EnvironmentObject var errorHandler: ErrorHandler

    let entity: IdentifiableEntity

    func body(content: Content) -> some View {
        content
            .onAppear {
                errorHandler.handle {
                    try entity.load(repo: data.repo)
                } dismissAction: {
                    dismiss()
                }
            }
    }
}

extension View {
    func loadEntity(_ entity: IdentifiableEntity) -> some View {
        modifier(LoadEntity(entity: entity))
    }
}

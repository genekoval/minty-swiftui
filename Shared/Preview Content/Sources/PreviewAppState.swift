import Foundation

extension AppState {
    static let preview: AppState = {
        let app = AppState()

        app.repo = PreviewRepo()

        return app
    }()
}

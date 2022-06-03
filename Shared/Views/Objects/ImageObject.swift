import SwiftUI

struct ImageObject<Content, Placeholder>: View where
    Content : View,
    Placeholder : View
{
    @EnvironmentObject var errorHandler: ErrorHandler
    @EnvironmentObject var objects: ObjectSource

    let id: UUID?

    let content: (Image) -> Content
    let placeholder: () -> Placeholder

    @State private var url: URL?

    var body: some View {
        AsyncImage(url: url) { image in
            content(
                image
                    .resizable()
            )
            .aspectRatio(contentMode: .fit)
        } placeholder: {
            placeholder()
        }
        .task {
            await fetchObject()
        }
    }

    init(id: UUID?) where
        Content == Image,
        Placeholder == ProgressView<EmptyView, EmptyView>
    {
        self.id = id
        content = { image in image }
        placeholder = { ProgressView() }
    }

    init(id: UUID?, placeholder: @escaping () -> Placeholder) where
        Content == Image
    {
        self.id = id
        self.content = { image in image }
        self.placeholder = placeholder
    }

    init(
        id: UUID?,
        content: @escaping (Image) -> Content,
        placeholder: @escaping () -> Placeholder
    ) {
        self.id = id
        self.content = content
        self.placeholder = placeholder
    }

    private func fetchObject() async {
        do {
            url = try await objects.url(for: id)
        }
        catch {
            errorHandler.handle(error: error)
        }
    }
}

struct ImageObject_Previews: PreviewProvider {
    static var previews: some View {
        ImageObject(id: PreviewObject.sandDune)
            .withErrorHandling()
            .environmentObject(ObjectSource.preview)
    }
}

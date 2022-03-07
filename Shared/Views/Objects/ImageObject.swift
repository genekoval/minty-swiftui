import SwiftUI

struct ImageObject<Content, Placeholder>: View where
    Content : View,
    Placeholder : View
{
    @EnvironmentObject var errorHandler: ErrorHandler
    @EnvironmentObject var objects: ObjectSource

    let id: String?

    let content: (Image) -> Content
    let placeholder: () -> Placeholder

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
    }

    private var url: URL? {
        do {
            return try objects.url(for: id)
        }
        catch {
            errorHandler.handle(error: error)
        }

        return nil
    }

    init(id: String?) where
        Content == Image,
        Placeholder == ProgressView<EmptyView, EmptyView>
    {
        self.id = id
        content = { image in image }
        placeholder = { ProgressView() }
    }

    init(id: String?, placeholder: @escaping () -> Placeholder) where
        Content == Image
    {
        self.id = id
        self.content = { image in image }
        self.placeholder = placeholder
    }

    init(
        id: String?,
        content: @escaping (Image) -> Content,
        placeholder: @escaping () -> Placeholder
    ) {
        self.id = id
        self.content = content
        self.placeholder = placeholder
    }
}

struct ImageObject_Previews: PreviewProvider {
    static var previews: some View {
        ImageObject(id: "sand dune.jpg")
            .withErrorHandling()
            .environmentObject(ObjectSource.preview)
    }
}

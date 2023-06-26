import Minty
import SwiftUI
import UniformTypeIdentifiers

private protocol Exportable: Transferable {
    var object: ObjectPreview { get }
    var source: ObjectSource { get }
}

@Sendable
private func export(
    _ exportable: some Exportable
) async throws -> SentTransferredFile {
    let url = try await exportable.source.url(for: exportable.object.id)
    return SentTransferredFile(url!)
}

private struct AudioExport: Exportable {
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .audio, exporting: export)
    }

    let object: ObjectPreview
    let source: ObjectSource
}


private struct DataExport: Exportable {
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .data, exporting: export)
    }

    let object: ObjectPreview
    let source: ObjectSource
}

private struct ImageExport: Exportable {
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .image, exporting: export)
    }

    let object: ObjectPreview
    let source: ObjectSource
}

private struct TextExport: Exportable {
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .text, exporting: export)
    }

    let object: ObjectPreview
    let source: ObjectSource
}

private struct VideoExport: Exportable {
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .video, exporting: export)
    }

    let object: ObjectPreview
    let source: ObjectSource
}

private struct ShareAudio: View {
    @EnvironmentObject private var source: ObjectSource

    let object: ObjectPreview

    var body: some View {
        ShareLink(
            item: AudioExport(object: object, source: source),
            preview: SharePreview(object.id.uuidString)
        )
    }
}

private struct ShareData: View {
    @EnvironmentObject private var source: ObjectSource

    let object: ObjectPreview

    var body: some View {
        ShareLink(
            item: DataExport(object: object, source: source),
            preview: SharePreview(object.id.uuidString)
        )
    }
}

private struct ShareImage: View {
    @EnvironmentObject private var source: ObjectSource

    let object: ObjectPreview

    var body: some View {
        ShareLink(
            item: ImageExport(object: object, source: source),
            preview: SharePreview(object.id.uuidString)
        )
    }
}

private struct ShareText: View {
    @EnvironmentObject private var source: ObjectSource

    let object: ObjectPreview

    var body: some View {
        ShareLink(
            item: TextExport(object: object, source: source),
            preview: SharePreview(object.id.uuidString)
        )
    }
}

private struct ShareVideo: View {
    @EnvironmentObject private var source: ObjectSource

    let object: ObjectPreview

    var body: some View {
        ShareLink(
            item: VideoExport(object: object, source: source),
            preview: SharePreview(object.id.uuidString)
        )
    }
}

struct ObjectShareLink: View {
    let object: ObjectPreview

    var body: some View {
        switch object.type {
        case "audio": ShareAudio(object: object)
        case "image": ShareImage(object: object)
        case "text": ShareText(object: object)
        case "video": ShareVideo(object: object)
        default: ShareData(object: object)
        }
    }
}

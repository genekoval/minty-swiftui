import Minty
import SwiftUI

private struct InfoField<Content>: View where Content : View {
    private let key: String
    private let value: () -> Content

    var body: some View {
        VStack {
            Divider()
                .padding(.horizontal)

            HStack {
                Text(key)
                    .foregroundColor(.secondary)
                    .padding(.trailing)

                Spacer()

                value()
                    .textSelection(.enabled)
            }
            .padding()
        }
    }

    init(key: String, @ViewBuilder value: @escaping () -> Content) {
        self.key = key
        self.value = value
    }
}

private struct KeyValue: View {
    let key: String
    let value: String

    var body: some View {
        InfoField(key: key) { Text(value) }
    }
}

struct ObjectDetail: View {
    @StateObject private var vm: ObjectViewModel

    var body: some View {
        PaddedScrollView {
            VStack(alignment: .leading) {
                if let object = vm.object {
                    HStack {
                        Spacer()
                        PreviewImage(
                            previewId: object.previewId,
                            type: object.type,
                            subtype: object.subtype
                        )
                        .frame(width: 150)
                        .padding(.bottom)
                        Spacer()
                    }

                    InfoField(key: "ID") {
                        Text(vm.id.uuidString)
                            .font(.caption)
                    }
                    KeyValue(key: "Type", value: object.mimeType)
                    InfoField(key: "Size") {
                        VStack(alignment: .trailing) {
                            Text(object.size.formatted)
                            Text("\(object.size.bytes) bytes")
                                .font(.caption)
                        }
                    }
                    InfoField(key: "Imported") {
                        VStack(alignment: .trailing) {
                            Text(object.dateAdded.relative(.full))
                            Spacer()
                            Text(object.dateAdded.string)
                                .font(.caption)
                        }
                    }
                    InfoField(key: "SHA 256") {
                        Text(object.hash)
                            .font(.caption)
                    }

                    if let source = object.source {
                        InfoField(key: "Source") {
                            SourceLink(source: source)
                        }
                    }
                }

                if !vm.posts.isEmpty {
                    KeyValue(key: "Posts", value: "\(vm.posts.count)")

                    ForEach(vm.posts) { PostLink(post: $0) }
                }
            }
        }
        .navigationTitle("Object")
        .navigationBarTitleDisplayMode(.inline)
        .loadEntity(vm)
    }

    init(id: UUID) {
        _vm = StateObject(wrappedValue: ObjectViewModel(id: id))
    }
}

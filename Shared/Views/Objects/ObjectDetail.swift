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
                HStack {
                    Spacer()
                    PreviewImage(
                        previewId: vm.object.previewId,
                        mimeType: vm.object.mimeType
                    )
                    .frame(width: 150)
                    .padding(.bottom)
                    Spacer()
                }

                InfoField(key: "ID") {
                    Text(vm.id)
                        .font(.caption)
                }
                KeyValue(key: "Type", value: vm.object.mimeType)
                InfoField(key: "Size") {
                    VStack(alignment: .trailing) {
                        Text(vm.object.size.formatted)
                        Text("\(vm.object.size.bytes) bytes")
                            .font(.caption)
                    }
                }
                InfoField(key: "Imported") {
                    VStack(alignment: .trailing) {
                        Text(vm.object.dateAdded.relative(.full))
                        Spacer()
                        Text(vm.object.dateAdded.string)
                            .font(.caption)
                    }
                }
                InfoField(key: "SHA 256") {
                    Text(vm.object.hash)
                        .font(.caption)
                }

                if let source = vm.object.source {
                    InfoField(key: "Source") {
                        SourceLink(source: source)
                    }
                }


                if !vm.object.posts.isEmpty {
                    KeyValue(key: "Posts", value: "\(vm.object.posts.count)")

                    ForEach($vm.object.posts) { post in
                        NavigationLink(destination: PostDetail(
                            id: post.id,
                            preview: post
                        )) {
                            PostRow(post: post.wrappedValue)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Object")
        .navigationBarTitleDisplayMode(.inline)
        .loadEntity(vm)
    }

    init(id: String, repo: MintyRepo?) {
        _vm = StateObject(wrappedValue: ObjectViewModel(id: id))
    }
}

struct ObjectDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            ObjectDetail(id: "sand dune.jpg", repo: PreviewRepo())
        }
        .environmentObject(DataSource.preview)
        .environmentObject(ObjectSource.preview)
    }
}

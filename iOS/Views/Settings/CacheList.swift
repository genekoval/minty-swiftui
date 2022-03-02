import SwiftUI

struct CacheList: View {
    @EnvironmentObject var objects: ObjectSource

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Objects")
                    Spacer()
                    Text("\(objects.cachedObjects.count)")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Size")
                    Spacer()
                    Text(objects.cacheSize.asByteCount)
                        .foregroundColor(.secondary)
                }
            }

            Section {
                ForEach(objects.cachedObjects) { object in
                    CacheRow(object: object)
                }
                .onDelete { offsets in
                    if let index = offsets.first {
                        objects.remove(at: index)
                    }
                }
            }
        }
        .playerSpacing()
        .navigationTitle("Cache")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CacheList_Previews: PreviewProvider {
    static var previews: some View {
        CacheList()
            .environmentObject(ObjectSource.preview)
    }
}

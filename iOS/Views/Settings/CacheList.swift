import SwiftUI

struct CacheList: View {
    @EnvironmentObject var errorHandler: ErrorHandler
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
                        errorHandler.handle {
                            try objects.remove(at: index)
                        }
                    }
                }
            }
        }
        .playerSpacing()
        .navigationTitle("Cache")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            Task {
                errorHandler.handle { try objects.refresh() }
            }
        }
    }
}

struct CacheList_Previews: PreviewProvider {
    static var previews: some View {
        CacheList()
            .withErrorHandling()
            .environmentObject(ObjectSource.preview)
    }
}

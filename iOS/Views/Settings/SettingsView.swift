import Minty
import SwiftUI

private struct IconLabel: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        Label {
            Text(title)
        } icon: {
            Circle()
                .fill(color)
                .overlay {
                    Image(systemName: icon)
                        .foregroundColor(.white)
                }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject private var errorHandler: ErrorHandler
    @EnvironmentObject private var objects: ObjectSource
    @EnvironmentObject private var settings: SettingsViewModel

    @State private var refreshing = false

    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: ServerView()) {
                    IconLabel(
                        title: "Server",
                        icon: "network",
                        color: .blue
                    )
                    .badge(settings.server?.host)
                }

                Section(header: Text("Cache")) {
                    HStack {
                        Text("Size")
                        Spacer()
                        Text(objects.cacheSize.asByteCount)
                            .foregroundColor(.secondary)
                    }


                    if !objects.cachedObjects.isEmpty {
                        NavigationLink(destination: CacheList()) {
                            Text("Inspect")
                        }

                        Button("Clear Cache") { clearCache() }
                    }
                }

                Section(header: Text("Help")) {
                    NavigationLink(destination: AboutView()) { Text("About") }
                    ResetButton { reset() }
                }
            }
            .playerSpacing()
            .navigationTitle("Settings")
            .onAppear { refreshCache() }
        }
    }

    private func clearCache() {
        errorHandler.handle { try objects.clearCache() }
    }

    private func refreshCache() {
        if !refreshing && objects.needsRefresh {
            refreshing = true

            Task {
                await objects.refresh()
                await MainActor.run { refreshing = false }
            }
        }
    }

    private func reset() {
        clearCache()
        settings.reset()
    }
}

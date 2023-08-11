import os
import Combine
import Foundation

private var cancellables = Set<AnyCancellable>()

final class SettingsViewModel: ObservableObject {
    @Published(key: "server") var server: URL? = nil
    @Published(key: "serverList") var serverList: [URL] = []

    func connect(to server: URL) {
        if server != self.server {
            serverList.remove(element: server)

            if let server = self.server {
                if !serverList.contains(server) {
                    serverList.insert(server, at: 0)
                }
            }
        }

        self.server = server
    }

    func reset() {
        if let bundleId = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleId)
        }
    }
}

extension Published where Value: Codable {
    init(wrappedValue defaultValue: Value, key: String) {
        let value = load(key) ?? defaultValue
        self.init(initialValue: value)
        projectedValue
            .sink { save(key, $0) }
            .store(in: &cancellables)
    }
}

private func load<T: Decodable>(
    _ key: String,
    defaults: UserDefaults = UserDefaults.standard
) -> T? {
    guard let saved = defaults.data(forKey: key)
    else {
        return nil
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: saved)
    }
    catch {
        Logger.settings.fault("Could not parse '\(key)' as \(T.self): \(error)")
    }

    return nil
}

private func save<T: Encodable>(
    _ key: String,
    _ item: T,
    defaults: UserDefaults = UserDefaults.standard
) {
    let data: Data
    let encoder = JSONEncoder()

    do {
        data = try encoder.encode(item)
    }
    catch {
        Logger.settings.fault("Could not encode item for key: \(key): \(error)")
        return
    }

    defaults.set(data, forKey: key)
}

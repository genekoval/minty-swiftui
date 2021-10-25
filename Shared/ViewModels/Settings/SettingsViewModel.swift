import Combine
import Foundation

private var cancellables: [String: AnyCancellable] = [:]

final class SettingsViewModel: ObservableObject {
    @Published(key: "server") var server: Server? = nil

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
        cancellables[key] = projectedValue.sink { save(key, $0) }
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
        fatalError("Could not parse `\(key)` as \(T.self):\n\(error)")
    }
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
        fatalError("Could not encode item for key: \(key):\n\(error)")
    }

    defaults.set(data, forKey: key)
}

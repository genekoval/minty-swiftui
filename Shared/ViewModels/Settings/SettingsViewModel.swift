import Combine
import Foundation

final class SettingsViewModel: ObservableObject {
    @Setting(key: "server", defaultValue: nil)
    var server: Server?

    func reset() {
        if let bundleId = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleId)
        }
    }
}

@propertyWrapper
struct Setting<Value: Codable> {
    private var key: String
    private var value: Value

    var wrappedValue: Value {
        get { value }
        set {
            value = newValue
            save(key, value)
        }
    }

    fileprivate init(key: String, defaultValue: Value) {
        self.key = key
        value = load(key) ?? defaultValue
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

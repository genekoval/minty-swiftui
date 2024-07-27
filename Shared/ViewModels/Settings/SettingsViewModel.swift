import os
import Combine
import Foundation
import Minty

private var cancellables = Set<AnyCancellable>()

final class SettingsViewModel: ObservableObject {
    @Published(key: "server") var server: Server? = nil
    @Published(key: "servers") var servers: [URL: [UUID: Account]] = [:]

    var account: Account? {
        guard let server,
              let user = server.user
        else { return nil }

        return servers[server.url]?[user]
    }

    var emails: [UUID: String] {
        guard let server,
              let accounts = servers[server.url]
        else {
            return [:]
        }

        return accounts.mapValues(\.email)
    }

    var otherAccounts: [(UUID, Account)] {
        guard let server,
              var accounts = servers[server.url]
        else { return [] }

        if let user = server.user {
            accounts.removeValue(forKey: user)
        }

        return Array(accounts)
    }

    var recentServers: [URL] {
        Array(servers.keys.filter { url in url != server?.url })
    }

    func addAccount(id: UUID, email: String, username: String? = nil) {
        guard let server else { return }

        servers[server.url, default: [:]][id] = Account(
            email: email,
            name: username ?? ""
        )

        self.server!.user = id
    }

    func connect(to server: URL) {
        if servers[server] == nil {
            servers[server] = [:]
        }

        self.server = Server(url: server)
    }

    func removeAccount() {
        guard let server else { return }
        removeAccount(for: server)
        self.server?.user = nil
    }

    func removeAccount(for server: Server) {
        guard let user = server.user else { return }
        servers[server.url]?.removeValue(forKey: user)
    }

    func reset() {
        if let bundleId = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleId)
        }
    }

    func updateAccount(using user: Minty.User) {
        guard let server,
              var account = servers[server.url]?[user.id]
        else {
            return
        }

        if account.update(using: user) {
            servers[server.url]?[user.id] = account
        }
    }

    func updateEmail(to email: String) {
        guard let server,
              let id = server.user,
              var account = servers[server.url]?[id]
        else {
            return
        }

        if account.updateEmail(to: email) {
            servers[server.url]?[id] = account
        }
    }
}

extension Published where Value: Codable {
    init(wrappedValue defaultValue: Value, key: String) {
        let value = load(key) ?? defaultValue

        self.init(initialValue: value)

        projectedValue
            .dropFirst()
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
        let value = try decoder.decode(T.self, from: saved)

        Logger.settings.debug("Loaded value for '\(key)'")

        return value
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
    Logger.settings.debug("Saved new value for \(key)")
}

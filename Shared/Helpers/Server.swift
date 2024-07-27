import Foundation
import Minty
import os

struct Account: Codable {
    var email: String
    var name: String

    mutating func update(using user: Minty.User) -> Bool {
        var updated = false

        if email != user.email {
            email = user.email
            updated = true
        }

        if name != user.profile.name {
            name = user.profile.name
            updated = true
        }

        return updated
    }

    mutating func updateEmail(to email: String) -> Bool {
        if email != self.email {
            self.email = email
            return true
        }

        return false
    }
}

struct Server: Codable, Equatable, Hashable {
    let url: URL

    var user: UUID?
}

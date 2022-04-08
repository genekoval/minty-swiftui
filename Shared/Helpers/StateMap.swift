private struct Weak<Element> where Element: AnyObject {
    weak var element: Element?
}

class StateMap<Element> where Element: AnyObject & Identifiable {
    private var storage: [Element.ID: Weak<Element>] = [:]

    var count: Int {
        storage.count
    }

    subscript(key: Element.ID) -> Element? {
        get {
            storage[key]?.element
        }

        set(newValue) {
            storage[key] = Weak(element: newValue)
        }
    }

    func remove(_ element: Element) {
        storage.removeValue(forKey: element.id)
    }
}

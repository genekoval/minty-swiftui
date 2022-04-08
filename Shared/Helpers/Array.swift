extension Array where Element: Equatable {
    mutating func remove(all elements: [Element]) {
        for element in elements {
            self.remove(element: element)
        }
    }

    @discardableResult
    mutating func remove(element: Element) -> Element? {
        if let index = self.firstIndex(of: element) {
            return self.remove(at: index)
        }

        return nil
    }
}

extension Array where Element: Identifiable {
    @discardableResult
    mutating func remove(id: Element.ID) -> Element? {
        if let index = self.firstIndex(where: { $0.id == id }) {
            return self.remove(at: index)
        }

        return nil
    }
}

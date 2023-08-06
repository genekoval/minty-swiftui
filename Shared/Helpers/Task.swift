extension Task where Success == Void, Failure == Never {
    @discardableResult
    static func after(
        _ delay: ContinuousClock.Instant.Duration,
        perform: @escaping () -> Success
    ) -> Self {
        Self {
            do {
                try await Task<Never, Never>.sleep(for: delay)
            }
            catch {
                return
            }

            perform()
        }
    }
}

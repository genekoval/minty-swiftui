private typealias Stream = AsyncStream<@Sendable () async -> Void>

final class TaskStream: Sendable {
    private let continuation: Stream.Continuation

    init(priority: TaskPriority = .medium) {
        var streamContinuation: Stream.Continuation? = nil
        let stream = Stream { continuation in
            streamContinuation = continuation
        }
        self.continuation = streamContinuation!

        Task.detached(priority: priority) {
            for await task in stream {
                await task()
            }
        }
    }

    deinit {
        continuation.finish()
    }

    func enqueueAndWait<T>(
        _ task: @escaping @Sendable () async throws -> T
    ) async throws -> T {
        try await withUnsafeThrowingContinuation { continuation in
            self.continuation.yield {
                do {
                    continuation.resume(returning: try await task())
                }
                catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

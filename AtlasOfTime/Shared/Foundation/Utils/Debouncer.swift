import Foundation

actor Debouncer {
    private var task: Task<Void, Never>?
    private var latestToken: UInt64 = 0

    func schedule(
        token: UInt64,
        delayNanoseconds: UInt64,
        operation: @escaping @Sendable () async -> Void
    ) {
        guard token >= latestToken else { return }

        latestToken = token
        task?.cancel()

        task = Task {
            do {
                try await Task.sleep(nanoseconds: delayNanoseconds)
                guard !Task.isCancelled else { return }
                await operation()
            } catch {
                // Cancellation during debounce window.
            }
        }
    }

    func cancelAll() {
        latestToken &+= 1
        task?.cancel()
        task = nil
    }
}

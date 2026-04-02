import Foundation

public struct LoadYearIndex: Sendable {
    private let repository: any YearIndexRepository

    public init(repository: any YearIndexRepository) {
        self.repository = repository
    }

    public func execute() async throws -> YearIndex {
        try await repository.load()
    }
}

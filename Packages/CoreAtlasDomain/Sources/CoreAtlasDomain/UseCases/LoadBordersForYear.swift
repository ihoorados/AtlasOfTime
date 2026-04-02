import Foundation

public struct LoadBordersForYear: Sendable {
    private let repository: any BorderRepository

    public init(repository: any BorderRepository) {
        self.repository = repository
    }

    public func execute(year: Int) async throws -> YearSnapshot {
        try await repository.snapshot(for: year)
    }
}

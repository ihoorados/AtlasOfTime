import Foundation

struct LoadBordersForYear: Sendable {
    private let repository: any BorderRepository

    init(repository: any BorderRepository) {
        self.repository = repository
    }

    func execute(year: Int) async throws -> YearSnapshot {
        try await repository.snapshot(for: year)
    }
}

import Foundation

struct LoadYearIndex: Sendable {
    private let repository: any YearIndexRepository

    init(repository: any YearIndexRepository) {
        self.repository = repository
    }

    func execute() async throws -> YearIndex {
        try await repository.load()
    }
}

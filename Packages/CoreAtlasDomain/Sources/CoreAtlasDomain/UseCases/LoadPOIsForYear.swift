import Foundation

public struct LoadPOIsForYear: Sendable {
    private let repository: any POIRepository

    public init(repository: any POIRepository) {
        self.repository = repository
    }

    public func execute(year: Int) async throws -> [HistoricalPOI] {
        try await repository.pointsOfInterest(for: year)
    }
}

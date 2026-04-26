import Foundation

public protocol POIRepository: Sendable {
    func pointsOfInterest(for year: Int) async throws -> [HistoricalPOI]
}

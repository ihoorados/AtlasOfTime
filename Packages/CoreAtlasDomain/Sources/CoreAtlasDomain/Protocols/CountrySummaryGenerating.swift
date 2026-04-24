import Foundation

public protocol CountrySummaryGenerating: Sendable {
    func generateSummary(for request: CountrySummaryRequest) async throws -> CountrySummaryResult
}

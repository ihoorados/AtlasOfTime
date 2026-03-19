import Foundation

protocol CountrySummaryGenerating: Sendable {
    func generateSummary(for request: CountrySummaryRequest) async throws -> CountrySummaryResult
}

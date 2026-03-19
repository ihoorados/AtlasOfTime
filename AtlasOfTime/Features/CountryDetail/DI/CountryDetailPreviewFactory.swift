import Foundation

@MainActor
enum CountryDetailPreviewFactory {
    static func makeFeatureContainer() -> CountryDetailFeatureDIContainer {
        CountryDetailFeatureDIContainer(
            generateCountrySummary: GenerateCountrySummary(
                generator: PreviewCountrySummaryGenerator()
            )
        )
    }

    static func makeScene(snapshot: HistoricalCountrySnapshot) -> CountryDetailScene {
        makeFeatureContainer().makeCountryDetailScene(snapshot: snapshot)
    }

    static func makeViewModel(snapshot: HistoricalCountrySnapshot) -> CountryDetailViewModel {
        makeFeatureContainer().makeCountryDetailViewModel(snapshot: snapshot)
    }
}

private struct PreviewCountrySummaryGenerator: CountrySummaryGenerating {
    func generateSummary(for request: CountrySummaryRequest) async throws -> CountrySummaryResult {
        CountrySummaryResult(
            title: request.displayName,
            summary: "\(request.displayName) is shown here for \(request.year). This preview summary is generated through the app-owned country detail boundary.",
            keyFacts: [
                "Name confidence: \(request.nameConfidence.rawValue)",
                "Border confidence: \(request.borderConfidence.rawValue)",
                "Relationships included: \(request.relationships.count)"
            ],
            confidenceNote: "Preview content only."
        )
    }
}

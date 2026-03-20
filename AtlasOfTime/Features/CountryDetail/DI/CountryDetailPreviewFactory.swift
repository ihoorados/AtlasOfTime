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
            overview: "\(request.displayName) is shown here for \(request.year). This preview summary is generated through the app-owned country detail boundary and reflects the structured request contract used by the detail feature.",
            territorialContext: "The preview request reports \(request.extentCount) extent configuration(s) with border confidence marked as \(request.borderConfidence.rawValue).",
            politicalContext: request.relationshipCount > 0 ? "The preview input includes \(request.relationshipCount) relationship record(s), which would be summarized here when they materially clarify status." : nil,
            keyFacts: [
                "Name confidence: \(request.nameConfidence.rawValue)",
                "Border confidence: \(request.borderConfidence.rawValue)",
                "Extent types: \(request.extentTypes.map(\.rawValue).joined(separator: ", "))",
                "Relationships included: \(request.relationshipCount)",
                "Sources included: \(request.sourceCount)"
            ],
            confidenceNote: "Preview content only."
        )
    }
}

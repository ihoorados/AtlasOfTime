import Foundation
import FoundationModels
import CoreAtlasDomain

@available(iOS 26.0, *)
struct FoundationModelCountrySummaryGenerator: CountrySummaryGenerating, Sendable {
    private let model: SystemLanguageModel
    private let promptBuilder: CountrySummaryPromptBuilder

    init(
        model: SystemLanguageModel = .default,
        promptBuilder: CountrySummaryPromptBuilder = CountrySummaryPromptBuilder()
    ) {
        self.model = model
        self.promptBuilder = promptBuilder
    }

    func generateSummary(for request: CountrySummaryRequest) async throws -> CountrySummaryResult {
        guard model.isAvailable else {
            throw CountrySummaryGenerationError.modelUnavailable(reason: unavailableReasonDescription(from: model.availability))
        }

        let session = LanguageModelSession(
            model: model,
            instructions: promptBuilder.instructions
        )

        let response = try await session.respond(
            to: promptBuilder.makePrompt(for: request),
            generating: CountrySummaryPayload.self
        )

        return CountrySummaryResult(
            title: response.content.title,
            overview: response.content.overview,
            territorialContext: response.content.territorialContext,
            politicalContext: response.content.politicalContext,
            keyFacts: response.content.keyFacts,
            confidenceNote: response.content.confidenceNote
        )
    }

    private func unavailableReasonDescription(
        from availability: SystemLanguageModel.Availability
    ) -> String {
        switch availability {
        case .available:
            "unknown"
        case .unavailable(let reason):
            switch reason {
            case .appleIntelligenceNotEnabled:
                "Apple Intelligence is not enabled."
            case .deviceNotEligible:
                "This device is not eligible for the system language model."
            case .modelNotReady:
                "The system language model is not ready yet."
            @unknown default:
                "The system language model is unavailable for an unknown reason."
            }
        }
    }
}

@available(iOS 26.0, *)
private enum CountrySummaryGenerationError: LocalizedError, Sendable {
    case modelUnavailable(reason: String)

    var errorDescription: String? {
        switch self {
        case .modelUnavailable(let reason):
            "Country summary generation is unavailable. \(reason)"
        }
    }
}

@available(iOS 26.0, *)
@Generable
private struct CountrySummaryPayload {
    let title: String
    let overview: String
    let territorialContext: String?
    let politicalContext: String?
    let keyFacts: [String]
    let confidenceNote: String?
}

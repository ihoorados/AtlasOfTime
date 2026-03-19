import Foundation

struct CountrySummaryResult: Equatable, Sendable {
    let title: String
    let summary: String
    let keyFacts: [String]
    let confidenceNote: String?

    init(
        title: String,
        summary: String,
        keyFacts: [String] = [],
        confidenceNote: String? = nil
    ) {
        self.title = title
        self.summary = summary
        self.keyFacts = keyFacts
        self.confidenceNote = confidenceNote
    }
}

import Foundation

struct CountrySummaryResult: Equatable, Sendable {
    let title: String
    let overview: String
    let territorialContext: String?
    let politicalContext: String?
    let keyFacts: [String]
    let confidenceNote: String?

    init(
        title: String,
        overview: String,
        territorialContext: String? = nil,
        politicalContext: String? = nil,
        keyFacts: [String] = [],
        confidenceNote: String? = nil
    ) {
        self.title = title
        self.overview = overview
        self.territorialContext = territorialContext
        self.politicalContext = politicalContext
        self.keyFacts = keyFacts
        self.confidenceNote = confidenceNote
    }
}

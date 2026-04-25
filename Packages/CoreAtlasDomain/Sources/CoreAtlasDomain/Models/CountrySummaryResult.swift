import Foundation

public struct CountrySummaryResult: Equatable, Sendable {
    public let title: String
    public let overview: String
    public let territorialContext: String?
    public let politicalContext: String?
    public let keyFacts: [String]
    public let confidenceNote: String?

    public init(
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

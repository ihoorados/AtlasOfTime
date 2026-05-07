import Foundation

public enum POICategory: String, Equatable, Hashable, Sendable, Codable {
    case battle
    case war
    case treaty
    case politicalEvent
    case culturalEvent
    case disaster
    case other
}

public struct HistoricalPOI: Identifiable, Equatable, Hashable, Sendable, Codable {
    public let id: String
    public let year: Int
    public let title: String
    public let summary: String
    public let coordinate: Coordinate
    public let category: POICategory
    public let confidence: HistoricalConfidence
    public let relatedCountryIDs: [String]
    public let sourceReferences: [HistoricalSourceReference]

    public init(
        id: String,
        year: Int,
        title: String,
        summary: String,
        coordinate: Coordinate,
        category: POICategory,
        confidence: HistoricalConfidence = .unknown,
        relatedCountryIDs: [String] = [],
        sourceReferences: [HistoricalSourceReference] = []
    ) {
        self.id = id
        self.year = year
        self.title = title
        self.summary = summary
        self.coordinate = coordinate
        self.category = category
        self.confidence = confidence
        self.relatedCountryIDs = relatedCountryIDs
        self.sourceReferences = sourceReferences
    }
}

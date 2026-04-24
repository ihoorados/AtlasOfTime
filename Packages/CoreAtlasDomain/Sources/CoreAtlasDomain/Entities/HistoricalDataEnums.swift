import Foundation

public enum HistoricalConfidence: String, Equatable, Hashable, Sendable, Codable {
    case high
    case medium
    case low
    case unknown
}

public enum HistoricalExtentType: String, Equatable, Hashable, Sendable, Codable {
    case control
    case claim
    case influence
    case frontierZone
}

public enum HistoricalBorderModel: String, Equatable, Hashable, Sendable, Codable {
    case preciseLine
    case approximateLine
    case lineWithUncertainty
    case zone
}

public enum HistoricalRelationshipType: String, Equatable, Hashable, Sendable, Codable {
    case subjectOf
    case partOf
}

public enum HistoricalRelationshipBasis: String, Equatable, Hashable, Sendable, Codable {
    case assertedBySource
    case inferred
    case unknown
}

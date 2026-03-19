import Foundation

enum HistoricalConfidence: String, Equatable, Sendable, Codable {
    case high
    case medium
    case low
    case unknown
}

enum HistoricalExtentType: String, Equatable, Sendable, Codable {
    case control
    case claim
    case influence
    case frontierZone
}

enum HistoricalBorderModel: String, Equatable, Sendable, Codable {
    case preciseLine
    case approximateLine
    case lineWithUncertainty
    case zone
}

enum HistoricalRelationshipType: String, Equatable, Sendable, Codable {
    case subjectOf
    case partOf
}

enum HistoricalRelationshipBasis: String, Equatable, Sendable, Codable {
    case assertedBySource
    case inferred
    case unknown
}

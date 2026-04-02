import Foundation

public struct HistoricalRelationship: Identifiable, Equatable, Hashable, Sendable, Codable {
    public let id: String
    public let type: HistoricalRelationshipType
    public let targetEntityID: String
    public let targetDisplayName: String
    public let basis: HistoricalRelationshipBasis
    public let confidence: HistoricalConfidence
    public let sourceReferences: [HistoricalSourceReference]

    public init(
        id: String,
        type: HistoricalRelationshipType,
        targetEntityID: String,
        targetDisplayName: String,
        basis: HistoricalRelationshipBasis = .unknown,
        confidence: HistoricalConfidence = .unknown,
        sourceReferences: [HistoricalSourceReference] = []
    ) {
        self.id = id
        self.type = type
        self.targetEntityID = targetEntityID
        self.targetDisplayName = targetDisplayName
        self.basis = basis
        self.confidence = confidence
        self.sourceReferences = sourceReferences
    }
}

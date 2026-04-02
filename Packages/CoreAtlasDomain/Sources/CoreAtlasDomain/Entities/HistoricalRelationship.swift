import Foundation

struct HistoricalRelationship: Identifiable, Equatable, Hashable, Sendable, Codable {
    let id: String
    let type: HistoricalRelationshipType
    let targetEntityID: String
    let targetDisplayName: String
    let basis: HistoricalRelationshipBasis
    let confidence: HistoricalConfidence
    let sourceReferences: [HistoricalSourceReference]

    init(
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

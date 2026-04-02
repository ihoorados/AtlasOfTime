import Foundation

public struct HistoricalCountrySnapshot: Identifiable, Equatable, Hashable, Sendable, Codable {
    public let id: String
    public let entityID: String
    public let year: Int
    public let displayName: String
    public let shortDisplayName: String?
    public let formalName: String?
    public let nameConfidence: HistoricalConfidence
    public let extents: [HistoricalExtent]
    public let relationships: [HistoricalRelationship]
    public let sourceReferences: [HistoricalSourceReference]

    public init(
        id: String,
        entityID: String,
        year: Int,
        displayName: String,
        shortDisplayName: String? = nil,
        formalName: String? = nil,
        nameConfidence: HistoricalConfidence = .unknown,
        extents: [HistoricalExtent],
        relationships: [HistoricalRelationship] = [],
        sourceReferences: [HistoricalSourceReference] = []
    ) {
        self.id = id
        self.entityID = entityID
        self.year = year
        self.displayName = displayName
        self.shortDisplayName = shortDisplayName
        self.formalName = formalName
        self.nameConfidence = nameConfidence
        self.extents = extents
        self.relationships = relationships
        self.sourceReferences = sourceReferences
    }
}

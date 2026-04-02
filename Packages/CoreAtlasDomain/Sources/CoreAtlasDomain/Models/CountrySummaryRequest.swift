import Foundation

public struct CountrySummaryRequest: Equatable, Sendable {
    public let year: Int
    public let countryID: String
    public let entityID: String
    public let displayName: String
    public let shortDisplayName: String?
    public let formalName: String?
    public let nameConfidence: HistoricalConfidence
    public let borderConfidence: HistoricalConfidence
    public let extentCount: Int
    public let extentTypes: [HistoricalExtentType]
    public let borderModels: [HistoricalBorderModel]
    public let hasMultipleExtents: Bool
    public let relationshipCount: Int
    public let sourceCount: Int
    public let relationships: [RelationshipContext]
    public let sourceReferences: [SourceContext]

    public init(
        year: Int,
        countryID: String,
        entityID: String,
        displayName: String,
        shortDisplayName: String? = nil,
        formalName: String? = nil,
        nameConfidence: HistoricalConfidence = .unknown,
        borderConfidence: HistoricalConfidence = .unknown,
        extentCount: Int = 0,
        extentTypes: [HistoricalExtentType] = [],
        borderModels: [HistoricalBorderModel] = [],
        hasMultipleExtents: Bool = false,
        relationshipCount: Int = 0,
        sourceCount: Int = 0,
        relationships: [RelationshipContext] = [],
        sourceReferences: [SourceContext] = []
    ) {
        self.year = year
        self.countryID = countryID
        self.entityID = entityID
        self.displayName = displayName
        self.shortDisplayName = shortDisplayName
        self.formalName = formalName
        self.nameConfidence = nameConfidence
        self.borderConfidence = borderConfidence
        self.extentCount = extentCount
        self.extentTypes = extentTypes
        self.borderModels = borderModels
        self.hasMultipleExtents = hasMultipleExtents
        self.relationshipCount = relationshipCount
        self.sourceCount = sourceCount
        self.relationships = relationships
        self.sourceReferences = sourceReferences
    }
}

public extension CountrySummaryRequest {
    struct RelationshipContext: Equatable, Sendable {
        public let type: HistoricalRelationshipType
        public let targetDisplayName: String
        public let confidence: HistoricalConfidence

        public init(
            type: HistoricalRelationshipType,
            targetDisplayName: String,
            confidence: HistoricalConfidence = .unknown
        ) {
            self.type = type
            self.targetDisplayName = targetDisplayName
            self.confidence = confidence
        }
    }

    struct SourceContext: Equatable, Sendable {
        public let title: String
        public let locator: String?
        public let note: String?

        public init(
            title: String,
            locator: String? = nil,
            note: String? = nil
        ) {
            self.title = title
            self.locator = locator
            self.note = note
        }
    }
}

import Foundation

struct CountrySummaryRequest: Equatable, Sendable {
    let year: Int
    let countryID: String
    let entityID: String
    let displayName: String
    let shortDisplayName: String?
    let formalName: String?
    let nameConfidence: HistoricalConfidence
    let borderConfidence: HistoricalConfidence
    let extentCount: Int
    let extentTypes: [HistoricalExtentType]
    let borderModels: [HistoricalBorderModel]
    let hasMultipleExtents: Bool
    let relationshipCount: Int
    let sourceCount: Int
    let relationships: [RelationshipContext]
    let sourceReferences: [SourceContext]

    init(
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

extension CountrySummaryRequest {
    struct RelationshipContext: Equatable, Sendable {
        let type: HistoricalRelationshipType
        let targetDisplayName: String
        let confidence: HistoricalConfidence

        init(
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
        let title: String
        let locator: String?
        let note: String?

        init(
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

import Foundation

struct HistoricalCountrySnapshot: Identifiable, Equatable, Sendable, Codable {
    let id: String
    let entityID: String
    let year: Int
    let displayName: String
    let shortDisplayName: String?
    let formalName: String?
    let nameConfidence: HistoricalConfidence
    let extents: [HistoricalExtent]
    let sourceReferences: [HistoricalSourceReference]

    init(
        id: String,
        entityID: String,
        year: Int,
        displayName: String,
        shortDisplayName: String? = nil,
        formalName: String? = nil,
        nameConfidence: HistoricalConfidence = .unknown,
        extents: [HistoricalExtent],
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
        self.sourceReferences = sourceReferences
    }
}

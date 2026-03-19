import Foundation

struct HistoricalExtent: Identifiable, Equatable, Hashable, Sendable, Codable {
    let id: String
    let extentType: HistoricalExtentType
    let borderModel: HistoricalBorderModel
    let borderPrecisionRank: Int?
    let borderConfidence: HistoricalConfidence
    let polygons: [GeoPolygon]
    let sourceReferences: [HistoricalSourceReference]

    init(
        id: String,
        extentType: HistoricalExtentType,
        borderModel: HistoricalBorderModel,
        borderPrecisionRank: Int? = nil,
        borderConfidence: HistoricalConfidence = .unknown,
        polygons: [GeoPolygon],
        sourceReferences: [HistoricalSourceReference] = []
    ) {
        self.id = id
        self.extentType = extentType
        self.borderModel = borderModel
        self.borderPrecisionRank = borderPrecisionRank
        self.borderConfidence = borderConfidence
        self.polygons = polygons
        self.sourceReferences = sourceReferences
    }
}

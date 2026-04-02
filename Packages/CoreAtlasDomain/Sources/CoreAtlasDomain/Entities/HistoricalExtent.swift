import Foundation

public struct HistoricalExtent: Identifiable, Equatable, Hashable, Sendable, Codable {
    public let id: String
    public let extentType: HistoricalExtentType
    public let borderModel: HistoricalBorderModel
    public let borderPrecisionRank: Int?
    public let borderConfidence: HistoricalConfidence
    public let polygons: [GeoPolygon]
    public let sourceReferences: [HistoricalSourceReference]

    public init(
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

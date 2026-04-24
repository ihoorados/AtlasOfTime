import Foundation

public struct HistoricalCountry: Identifiable, Equatable, Sendable {
    public let id: String
    public let displayName: String
    public let shortName: String?
    public let sovereignName: String?
    public let parentName: String?
    public let borderPrecision: Int?
    public let infoURL: URL?
    public let polygons: [GeoPolygon]

    public init(
        id: String,
        displayName: String,
        shortName: String? = nil,
        sovereignName: String? = nil,
        parentName: String? = nil,
        borderPrecision: Int? = nil,
        infoURL: URL? = nil,
        polygons: [GeoPolygon]
    ) {
        self.id = id
        self.displayName = displayName
        self.shortName = shortName
        self.sovereignName = sovereignName
        self.parentName = parentName
        self.borderPrecision = borderPrecision
        self.infoURL = infoURL
        self.polygons = polygons
    }
}

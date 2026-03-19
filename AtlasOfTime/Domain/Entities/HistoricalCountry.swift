import Foundation

struct HistoricalCountry: Identifiable, Equatable, Sendable {
    let id: String
    let displayName: String
    let shortName: String?
    let sovereignName: String?
    let parentName: String?
    let borderPrecision: Int?
    let infoURL: URL?
    let polygons: [GeoPolygon]

    init(
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

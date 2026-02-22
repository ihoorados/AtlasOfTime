import Foundation

struct YearSnapshot: Sendable {
    let year: Int
    let polygons: [GeoPolygon]
}

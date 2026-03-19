import Foundation

struct Coordinate: Hashable, Equatable, Sendable, Codable {
    let lat: Double
    let lon: Double
}

struct GeoPolygon: Equatable, Sendable, Codable {
    let outer: [Coordinate]
    let holes: [[Coordinate]]
}

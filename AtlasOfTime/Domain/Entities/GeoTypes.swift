import Foundation

struct Coordinate: Hashable, Equatable, Sendable, Codable {
    let lat: Double
    let lon: Double
}

struct GeoPolygon: Hashable, Equatable, Sendable, Codable {
    let outer: [Coordinate]
    let holes: [[Coordinate]]
}

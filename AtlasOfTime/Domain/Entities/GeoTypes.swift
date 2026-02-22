import Foundation

struct Coordinate: Hashable, Equatable, Sendable {
    let lat: Double
    let lon: Double
}

struct GeoPolygon: Equatable, Sendable {
    let outer: [Coordinate]
    let holes: [[Coordinate]]
}

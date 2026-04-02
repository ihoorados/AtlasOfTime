import Foundation

public struct Coordinate: Hashable, Equatable, Sendable, Codable {
    public let lat: Double
    public let lon: Double

    public init(lat: Double, lon: Double) {
        self.lat = lat
        self.lon = lon
    }
}

public struct GeoPolygon: Hashable, Equatable, Sendable, Codable {
    public let outer: [Coordinate]
    public let holes: [[Coordinate]]

    public init(outer: [Coordinate], holes: [[Coordinate]] = []) {
        self.outer = outer
        self.holes = holes
    }
}

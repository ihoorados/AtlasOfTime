import Foundation

public struct AtlasMapPolygon: Equatable, Hashable, Sendable, Codable {
    public let outerRing: [AtlasMapCoordinate]
    public let holes: [[AtlasMapCoordinate]]

    public init(
        outerRing: [AtlasMapCoordinate],
        holes: [[AtlasMapCoordinate]] = []
    ) {
        self.outerRing = outerRing
        self.holes = holes
    }
}

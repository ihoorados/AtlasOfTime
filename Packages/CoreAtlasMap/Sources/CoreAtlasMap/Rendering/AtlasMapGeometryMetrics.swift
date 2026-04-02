import Foundation

public enum AtlasMapGeometryMetrics {
    public static func signedArea(of ring: [AtlasMapCoordinate]) -> Double {
        guard ring.count > 2 else { return 0 }

        var area = 0.0
        for index in ring.indices {
            let nextIndex = ring.index(after: index) == ring.endIndex ? ring.startIndex : ring.index(after: index)
            let current = ring[index]
            let next = ring[nextIndex]
            area += (current.longitude * next.latitude) - (next.longitude * current.latitude)
        }
        return area / 2
    }

    public static func approximateArea(of polygon: AtlasMapPolygon) -> Double {
        abs(signedArea(of: polygon.outerRing)) - polygon.holes.reduce(0) { partialResult, ring in
            partialResult + abs(signedArea(of: ring))
        }
    }

    public static func centroid(of ring: [AtlasMapCoordinate]) -> AtlasMapCoordinate {
        guard ring.count > 2 else {
            let averageLatitude = ring.map(\.latitude).reduce(0, +) / Double(max(ring.count, 1))
            let averageLongitude = ring.map(\.longitude).reduce(0, +) / Double(max(ring.count, 1))
            return AtlasMapCoordinate(latitude: averageLatitude, longitude: averageLongitude)
        }

        var signedArea = 0.0
        var centroidLatitude = 0.0
        var centroidLongitude = 0.0

        for index in ring.indices {
            let nextIndex = ring.index(after: index) == ring.endIndex ? ring.startIndex : ring.index(after: index)
            let current = ring[index]
            let next = ring[nextIndex]
            let cross = (current.longitude * next.latitude) - (next.longitude * current.latitude)

            signedArea += cross
            centroidLongitude += (current.longitude + next.longitude) * cross
            centroidLatitude += (current.latitude + next.latitude) * cross
        }

        guard signedArea != 0 else {
            let averageLatitude = ring.map(\.latitude).reduce(0, +) / Double(ring.count)
            let averageLongitude = ring.map(\.longitude).reduce(0, +) / Double(ring.count)
            return AtlasMapCoordinate(latitude: averageLatitude, longitude: averageLongitude)
        }

        let areaFactor = signedArea * 3
        return AtlasMapCoordinate(
            latitude: centroidLatitude / areaFactor,
            longitude: centroidLongitude / areaFactor
        )
    }

    public static func representativeCoordinate(for polygon: AtlasMapPolygon) -> AtlasMapCoordinate? {
        guard !polygon.outerRing.isEmpty else { return nil }
        return centroid(of: polygon.outerRing)
    }
}

import Foundation
import OSLog

enum GeoJSONBorderDecoder {
    private static let logger = Logger(subsystem: "AtlasOfTime", category: "GeoJSONBorderDecoder")

    static func decode(data: Data) throws -> [GeoPolygon] {
        let collection: FeatureCollection
        do {
            collection = try JSONDecoder().decode(FeatureCollection.self, from: data)
        } catch {
            throw AppError.invalidGeoJSON(error.localizedDescription)
        }

        guard collection.type == "FeatureCollection" else {
            throw AppError.invalidGeoJSON("Root type must be FeatureCollection.")
        }

        var polygons: [GeoPolygon] = []

        for feature in collection.features {
            guard let geometry = feature.geometry else { continue }

            switch geometry.coordinates {
            case .polygon(let polygonRings):
                if let polygon = makePolygon(from: polygonRings) {
                    polygons.append(polygon)
                }

            case .multiPolygon(let multiPolygonRings):
                for polygonRings in multiPolygonRings {
                    if let polygon = makePolygon(from: polygonRings) {
                        polygons.append(polygon)
                    }
                }

            case .unsupported:
                logger.warning("Skipping unsupported geometry type: \(geometry.type, privacy: .public)")
            }
        }

        return polygons
    }

    private static func makePolygon(from rings: [[[Double]]]) -> GeoPolygon? {
        guard !rings.isEmpty else {
            logger.warning("Dropping polygon: missing rings.")
            return nil
        }

        guard let outer = normalizeRing(rings[0], role: "outer") else {
            logger.warning("Dropping polygon: invalid outer ring.")
            return nil
        }

        var holes: [[Coordinate]] = []
        for ring in rings.dropFirst() {
            if let hole = normalizeRing(ring, role: "hole") {
                holes.append(hole)
            }
        }

        return GeoPolygon(outer: outer, holes: holes)
    }

    // Allowed MVP mutations: close ring if needed; drop invalid rings (<4 points).
    private static func normalizeRing(_ rawRing: [[Double]], role: String) -> [Coordinate]? {
        guard !rawRing.isEmpty else {
            logger.warning("Dropping \(role, privacy: .public) ring: empty ring.")
            return nil
        }

        var ring: [Coordinate] = []
        ring.reserveCapacity(rawRing.count + 1)

        for rawPoint in rawRing {
            guard rawPoint.count >= 2 else {
                logger.warning("Dropping \(role, privacy: .public) ring: invalid coordinate tuple.")
                return nil
            }
            ring.append(Coordinate(lat: rawPoint[1], lon: rawPoint[0]))
        }

        if let first = ring.first, let last = ring.last, first != last {
            ring.append(first)
        }

        guard ring.count >= 4 else {
            logger.warning("Dropping \(role, privacy: .public) ring: fewer than 4 points.")
            return nil
        }

        return ring
    }
}

private struct FeatureCollection: Decodable {
    let type: String
    let features: [Feature]
}

private struct Feature: Decodable {
    let geometry: Geometry?
}

private struct Geometry: Decodable {
    let type: String
    let coordinates: CoordinatesPayload

    private enum CodingKeys: String, CodingKey {
        case type
        case coordinates
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)

        switch type {
        case "Polygon":
            coordinates = .polygon(try container.decode([[[Double]]].self, forKey: .coordinates))
        case "MultiPolygon":
            coordinates = .multiPolygon(try container.decode([[[[Double]]]].self, forKey: .coordinates))
        default:
            coordinates = .unsupported
        }
    }
}

private enum CoordinatesPayload {
    case polygon([[[Double]]])
    case multiPolygon([[[[Double]]]])
    case unsupported
}

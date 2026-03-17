import Foundation
import OSLog

enum GeoJSONBorderDecoder {
    private static let logger = Logger(subsystem: "AtlasOfTime", category: "GeoJSONBorderDecoder")

    static func decodeSnapshots(data: Data, year: Int) throws -> [HistoricalCountrySnapshot] {
        let collection: FeatureCollection
        do {
            collection = try JSONDecoder().decode(FeatureCollection.self, from: data)
        } catch {
            throw AppError.invalidGeoJSON(error.localizedDescription)
        }

        guard collection.type == "FeatureCollection" else {
            throw AppError.invalidGeoJSON("Root type must be FeatureCollection.")
        }

        var groupedCountries: [CountryGroupingKey: HistoricalCountryAccumulator] = [:]

        for feature in collection.features {
            guard let geometry = feature.geometry else { continue }
            let countryIdentity = makeCountryIdentity(from: feature.properties)
            let key = countryIdentity.groupingKey

            switch geometry.coordinates {
            case .polygon(let polygonRings):
                if let polygon = makePolygon(from: polygonRings) {
                    groupedCountries[key, default: .init(identity: countryIdentity)]
                        .polygons
                        .append(polygon)
                }

            case .multiPolygon(let multiPolygonRings):
                for polygonRings in multiPolygonRings {
                    if let polygon = makePolygon(from: polygonRings) {
                        groupedCountries[key, default: .init(identity: countryIdentity)]
                            .polygons
                            .append(polygon)
                    }
                }

            case .unsupported:
                logger.warning("Skipping unsupported geometry type: \(geometry.type, privacy: .public)")
            }
        }

        return groupedCountries.values
            .filter { !$0.polygons.isEmpty }
            .map { $0.snapshot(year: year) }
            .sorted { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
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

    private static func makeCountryIdentity(from properties: FeatureProperties) -> HistoricalCountryIdentity {
        let displayName = firstMeaningfulValue(
            properties.name,
            properties.abbreviatedName,
            properties.subjectOf,
            properties.partOf
        ) ?? "Unknown"

        let shortName = normalizedOptional(properties.abbreviatedName)
        let sovereignName = normalizedOptional(properties.subjectOf)
        let parentName = normalizedOptional(properties.partOf)
        let infoURL = normalizedOptional(properties.infoURL).flatMap(URL.init(string:))

        let groupingKey = CountryGroupingKey(
            displayName: normalizedKeyComponent(displayName) ?? "unknown",
            sovereignName: normalizedKeyComponent(sovereignName),
            parentName: normalizedKeyComponent(parentName)
        )

        let identifier = [
            groupingKey.displayName,
            groupingKey.sovereignName ?? "_",
            groupingKey.parentName ?? "_"
        ]
        .joined(separator: "|")

        return HistoricalCountryIdentity(
            id: identifier,
            displayName: displayName,
            shortName: shortName,
            sovereignName: sovereignName,
            parentName: parentName,
            borderPrecision: properties.borderPrecision,
            infoURL: infoURL,
            groupingKey: groupingKey
        )
    }

    private static func firstMeaningfulValue(_ values: String?...) -> String? {
        values.compactMap(normalizedOptional).first
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmed.isEmpty,
              trimmed.lowercased() != "null" else {
            return nil
        }

        return trimmed
    }

    private static func normalizedKeyComponent(_ value: String?) -> String? {
        normalizedOptional(value)?
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .lowercased()
    }
}

private struct FeatureCollection: Decodable {
    let type: String
    let features: [Feature]
}

private struct Feature: Decodable {
    let geometry: Geometry?
    let properties: FeatureProperties
}

private struct FeatureProperties: Decodable {
    let name: String?
    let abbreviatedName: String?
    let infoURL: String?
    let subjectOf: String?
    let borderPrecision: Int?
    let partOf: String?

    private enum CodingKeys: String, CodingKey {
        case name = "NAME"
        case abbreviatedName = "ABBREVN"
        case infoURL = "INFO_UR"
        case subjectOf = "SUBJECTO"
        case borderPrecision = "BORDERPRECISION"
        case partOf = "PARTOF"
    }
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

private struct CountryGroupingKey: Hashable {
    let displayName: String
    let sovereignName: String?
    let parentName: String?
}

private struct HistoricalCountryIdentity {
    let id: String
    let displayName: String
    let shortName: String?
    let sovereignName: String?
    let parentName: String?
    let borderPrecision: Int?
    let infoURL: URL?
    let groupingKey: CountryGroupingKey
}

private struct HistoricalCountryAccumulator {
    let identity: HistoricalCountryIdentity
    var polygons: [GeoPolygon] = []

    func snapshot(year: Int) -> HistoricalCountrySnapshot {
        let sourceReferences = makeSourceReferences()

        return HistoricalCountrySnapshot(
            id: identity.id,
            entityID: identity.id,
            year: year,
            displayName: identity.displayName,
            shortDisplayName: identity.shortName,
            formalName: nil,
            nameConfidence: .unknown,
            extents: [
                HistoricalExtent(
                    id: "\(identity.id)-extent-\(year)",
                    extentType: .control,
                    borderModel: borderModel,
                    borderPrecisionRank: identity.borderPrecision,
                    borderConfidence: borderConfidence,
                    polygons: polygons,
                    sourceReferences: sourceReferences
                )
            ],
            sourceReferences: sourceReferences
        )
    }

    private var borderModel: HistoricalBorderModel {
        switch identity.borderPrecision {
        case let value? where value >= 3:
            return .preciseLine
        case 2:
            return .lineWithUncertainty
        default:
            return .approximateLine
        }
    }

    private var borderConfidence: HistoricalConfidence {
        switch identity.borderPrecision {
        case let value? where value >= 3:
            return .high
        case 2:
            return .medium
        case 1:
            return .low
        default:
            return .unknown
        }
    }

    private func makeSourceReferences() -> [HistoricalSourceReference] {
        var references = [
            HistoricalSourceReference(
                id: "source:historical-geojson",
                title: "Imported Historical GeoJSON"
            )
        ]

        if let infoURL = identity.infoURL {
            references.append(
                HistoricalSourceReference(
                    id: infoURL.absoluteString,
                    title: "Feature Reference",
                    url: infoURL
                )
            )
        }

        return references
    }
}

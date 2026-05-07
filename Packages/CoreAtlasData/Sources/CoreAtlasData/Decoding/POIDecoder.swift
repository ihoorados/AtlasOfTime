import Foundation
import CoreAtlasDomain

public protocol POIDecoding: Sendable {
    func decodePOIs(from data: Data, year: Int) throws -> [HistoricalPOI]
}

public struct JSONPOIDecoderAdapter: POIDecoding {
    public init() {}

    public func decodePOIs(from data: Data, year: Int) throws -> [HistoricalPOI] {
        try POIDecoder.decodePOIs(from: data, year: year)
    }
}

public enum POIDecoder {
    private static let maximumPOIsPerYear = 10

    public static func decodePOIs(from data: Data, year: Int) throws -> [HistoricalPOI] {
        let payload: POIYearPayload
        do {
            payload = try JSONDecoder().decode(POIYearPayload.self, from: data)
        } catch {
            throw AtlasDataError.invalidPOIFormat(error.localizedDescription)
        }

        guard payload.year == year else {
            throw AtlasDataError.invalidPOIFormat("File year \(payload.year) does not match requested year \(year).")
        }

        guard payload.pointsOfInterest.count <= maximumPOIsPerYear else {
            throw AtlasDataError.invalidPOIFormat("Year \(year) contains more than \(maximumPOIsPerYear) POIs.")
        }

        return try payload.pointsOfInterest.map { try $0.toDomain(expectedYear: year) }
    }
}

private struct POIYearPayload: Decodable {
    let year: Int
    let pointsOfInterest: [POIRecord]
}

private struct POIRecord: Decodable {
    let id: String
    let year: Int
    let title: String
    let summary: String
    let latitude: Double
    let longitude: Double
    let category: POICategory
    let confidence: HistoricalConfidence
    let relatedCountryIDs: [String]
    let sourceReferences: [HistoricalSourceReference]

    func toDomain(expectedYear: Int) throws -> HistoricalPOI {
        guard year == expectedYear else {
            throw AtlasDataError.invalidPOIFormat("POI \(id) has year \(year), expected \(expectedYear).")
        }
        guard !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AtlasDataError.invalidPOIFormat("POI id must not be empty.")
        }
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AtlasDataError.invalidPOIFormat("POI \(id) title must not be empty.")
        }
        guard !summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AtlasDataError.invalidPOIFormat("POI \(id) summary must not be empty.")
        }
        guard (-90.0...90.0).contains(latitude), (-180.0...180.0).contains(longitude) else {
            throw AtlasDataError.invalidPOIFormat("POI \(id) has invalid coordinates.")
        }

        return HistoricalPOI(
            id: id,
            year: year,
            title: title,
            summary: summary,
            coordinate: Coordinate(lat: latitude, lon: longitude),
            category: category,
            confidence: confidence,
            relatedCountryIDs: relatedCountryIDs,
            sourceReferences: sourceReferences
        )
    }
}

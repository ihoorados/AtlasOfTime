import Foundation
import CoreAtlasDomain

protocol GzipDecoding: Sendable {
    func gunzip(_ data: Data) throws -> Data
}

protocol BorderDecoding: Sendable {
    func decodeSnapshots(from data: Data, year: Int) throws -> [HistoricalCountrySnapshot]
    func decodeCountries(from data: Data, year: Int) throws -> [HistoricalCountry]
    func decodeBorders(from data: Data) throws -> [GeoPolygon]
}

extension BorderDecoding {
    func decodeCountries(from data: Data, year: Int) throws -> [HistoricalCountry] {
        try decodeSnapshots(from: data, year: year)
            .map { snapshot in
                HistoricalCountry(
                    id: snapshot.id,
                    displayName: snapshot.displayName,
                    shortName: snapshot.shortDisplayName,
                    sovereignName: nil,
                    parentName: nil,
                    borderPrecision: snapshot.extents.first?.borderPrecisionRank,
                    infoURL: snapshot.sourceReferences.first?.url ?? snapshot.extents.first?.sourceReferences.first?.url,
                    polygons: snapshot.extents.flatMap(\.polygons)
                )
            }
    }

    func decodeBorders(from data: Data) throws -> [GeoPolygon] {
        try decodeSnapshots(from: data, year: 0)
            .flatMap { snapshot in
                snapshot.extents.flatMap(\.polygons)
            }
    }
}

struct CompressionGzipDecoderAdapter: GzipDecoding {
    func gunzip(_ data: Data) throws -> Data {
        try GzipDecoder.gunzip(data)
    }
}

struct GeoJSONBorderDecoderAdapter: BorderDecoding {
    func decodeSnapshots(from data: Data, year: Int) throws -> [HistoricalCountrySnapshot] {
        try GeoJSONBorderDecoder.decodeSnapshots(data: data, year: year)
    }
}

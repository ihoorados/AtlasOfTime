import Foundation

protocol GzipDecoding: Sendable {
    func gunzip(_ data: Data) throws -> Data
}

protocol BorderDecoding: Sendable {
    func decodeCountries(from data: Data) throws -> [HistoricalCountry]
    func decodeBorders(from data: Data) throws -> [GeoPolygon]
}

extension BorderDecoding {
    func decodeBorders(from data: Data) throws -> [GeoPolygon] {
        try decodeCountries(from: data)
            .flatMap(\.polygons)
    }
}

struct CompressionGzipDecoderAdapter: GzipDecoding {
    func gunzip(_ data: Data) throws -> Data {
        try GzipDecoder.gunzip(data)
    }
}

struct GeoJSONBorderDecoderAdapter: BorderDecoding {
    func decodeCountries(from data: Data) throws -> [HistoricalCountry] {
        try GeoJSONBorderDecoder.decodeCountries(data: data)
    }
}

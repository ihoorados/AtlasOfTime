import Foundation

protocol GzipDecoding: Sendable {
    func gunzip(_ data: Data) throws -> Data
}

protocol BorderDecoding: Sendable {
    func decodeBorders(from data: Data) throws -> [GeoPolygon]
}

struct CompressionGzipDecoderAdapter: GzipDecoding {
    func gunzip(_ data: Data) throws -> Data {
        try GzipDecoder.gunzip(data)
    }
}

struct GeoJSONBorderDecoderAdapter: BorderDecoding {
    func decodeBorders(from data: Data) throws -> [GeoPolygon] {
        try GeoJSONBorderDecoder.decode(data: data)
    }
}


import Foundation

protocol BorderSnapshotLoading: Sendable {
    func loadSnapshot(year: Int, relativePath: String) async throws -> YearSnapshot
}

struct DefaultBorderSnapshotLoader: BorderSnapshotLoading {
    private let dataSource: BundleDataSource
    private let gzipDecoder: any GzipDecoding
    private let borderDecoder: any BorderDecoding

    init(
        dataSource: BundleDataSource,
        gzipDecoder: any GzipDecoding,
        borderDecoder: any BorderDecoding
    ) {
        self.dataSource = dataSource
        self.gzipDecoder = gzipDecoder
        self.borderDecoder = borderDecoder
    }

    func loadSnapshot(year: Int, relativePath: String) async throws -> YearSnapshot {
        let compressedData = try dataSource.readYearFile(relativePath: relativePath)
        let geoJSONData = try gzipDecoder.gunzip(compressedData)
        let polygons = try borderDecoder.decodeBorders(from: geoJSONData)
        return YearSnapshot(year: year, polygons: polygons)
    }
}

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
        try Task.checkCancellation()

        let compressedData = try dataSource.readYearFile(relativePath: relativePath)
        try Task.checkCancellation()

        let geoJSONData = try gzipDecoder.gunzip(compressedData)
        try Task.checkCancellation()

        let polygons = try borderDecoder.decodeBorders(from: geoJSONData)
        try Task.checkCancellation()

        return YearSnapshot(year: year, polygons: polygons)
    }
}

import Foundation
import CoreAtlasDomain

protocol BorderSnapshotLoading: Sendable {
    func loadSnapshot(year: Int, relativePath: String) async throws -> YearSnapshot
}

struct DefaultBorderSnapshotLoader: BorderSnapshotLoading {
    private let yearFileReader: any YearFileReading
    private let gzipDecoder: any GzipDecoding
    private let borderDecoder: any BorderDecoding

    init(
        yearFileReader: any YearFileReading,
        gzipDecoder: any GzipDecoding,
        borderDecoder: any BorderDecoding
    ) {
        self.yearFileReader = yearFileReader
        self.gzipDecoder = gzipDecoder
        self.borderDecoder = borderDecoder
    }

    func loadSnapshot(year: Int, relativePath: String) async throws -> YearSnapshot {
        try Task.checkCancellation()

        let compressedData = try yearFileReader.readYearFile(relativePath: relativePath)
        try Task.checkCancellation()

        let geoJSONData = try gzipDecoder.gunzip(compressedData)
        try Task.checkCancellation()

        let snapshots = try borderDecoder.decodeSnapshots(from: geoJSONData, year: year)
        try Task.checkCancellation()

        return YearSnapshot(year: year, snapshots: snapshots)
    }
}

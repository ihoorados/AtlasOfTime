import Foundation
import CoreAtlasDomain

public actor DefaultPOIRepository: POIRepository {
    private let fileReader: any POIFileReading
    private let decoder: any POIDecoding
    private let pathForYear: @Sendable (Int) -> String
    private var cachedPOIs: [Int: [HistoricalPOI]] = [:]
    private var inFlightPOIs: [Int: Task<[HistoricalPOI], Error>] = [:]

    public init(
        fileReader: any POIFileReading,
        decoder: any POIDecoding = JSONPOIDecoderAdapter(),
        pathForYear: @escaping @Sendable (Int) -> String = { "poi/\($0).json" }
    ) {
        self.fileReader = fileReader
        self.decoder = decoder
        self.pathForYear = pathForYear
    }

    public func pointsOfInterest(for year: Int) async throws -> [HistoricalPOI] {
        if let cached = cachedPOIs[year] {
            return cached
        }

        if let inFlightTask = inFlightPOIs[year] {
            return try await inFlightTask.value
        }

        let relativePath = pathForYear(year)
        let task = Task<[HistoricalPOI], Error> { [fileReader, decoder] in
            try Task.checkCancellation()
            let data: Data
            do {
                data = try fileReader.readPOIFile(relativePath: relativePath)
            } catch {
                if let dataError = error as? AtlasDataError, case .resourceNotFound = dataError {
                    return []
                }
                throw error
            }
            try Task.checkCancellation()
            return try decoder.decodePOIs(from: data, year: year)
        }
        inFlightPOIs[year] = task
        defer { inFlightPOIs[year] = nil }

        let pois = try await task.value
        try Task.checkCancellation()
        cachedPOIs[year] = pois
        return pois
    }
}

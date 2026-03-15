import Foundation

actor DefaultBorderRepository: BorderRepository {
    private let dataSource: BundleDataSource
    private let cache: LRUCache<Int, YearSnapshot>
    private let yearIndexRepository: any YearIndexRepository
    private let gzipDecoder: any GzipDecoding
    private let borderDecoder: any BorderDecoding
    private var cachedYearIndex: YearIndex?

    init(
        dataSource: BundleDataSource,
        cache: LRUCache<Int, YearSnapshot>,
        yearIndexRepository: any YearIndexRepository,
        gzipDecoder: any GzipDecoding,
        borderDecoder: any BorderDecoding
    ) {
        self.dataSource = dataSource
        self.cache = cache
        self.yearIndexRepository = yearIndexRepository
        self.gzipDecoder = gzipDecoder
        self.borderDecoder = borderDecoder
    }

    func snapshot(for year: Int) async throws -> YearSnapshot {
        if let cached = await cache.value(for: year) {
            return cached
        }

        let index = try await currentYearIndex()
        guard let relativePath = index.path(for: year) else {
            throw AppError.yearUnavailable(year)
        }

        let compressedData = try dataSource.readYearFile(relativePath: relativePath)
        let geoJSONData = try gzipDecoder.gunzip(compressedData)
        let polygons = try borderDecoder.decodeBorders(from: geoJSONData)

        let snapshot = YearSnapshot(year: year, polygons: polygons)
        await cache.setValue(snapshot, for: year)
        return snapshot
    }

    private func currentYearIndex() async throws -> YearIndex {
        if let cachedYearIndex {
            return cachedYearIndex
        }

        let loaded = try await yearIndexRepository.load()
        cachedYearIndex = loaded
        return loaded
    }
}

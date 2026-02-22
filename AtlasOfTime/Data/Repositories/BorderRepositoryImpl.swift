import Foundation

actor BorderRepositoryImpl: BorderRepository {
    typealias YearIndexProvider = @Sendable () async throws -> YearIndex

    private let dataSource: BundleDataSource
    private let cache: LRUCache<Int, YearSnapshot>
    private let yearIndexProvider: YearIndexProvider

    init(
        dataSource: BundleDataSource,
        cache: LRUCache<Int, YearSnapshot>,
        yearIndexProvider: @escaping YearIndexProvider
    ) {
        self.dataSource = dataSource
        self.cache = cache
        self.yearIndexProvider = yearIndexProvider
    }

    func snapshot(for year: Int) async throws -> YearSnapshot {
        if let cached = await cache.value(for: year) {
            return cached
        }

        let index = try await yearIndexProvider()
        guard let relativePath = index.path(for: year) else {
            throw AppError.yearUnavailable(year)
        }

        let compressedData = try dataSource.readYearFile(relativePath: relativePath)
        let geoJSONData = try GzipDecoder.gunzip(compressedData)
        let polygons = try GeoJSONBorderDecoder.decode(data: geoJSONData)

        let snapshot = YearSnapshot(year: year, polygons: polygons)
        await cache.setValue(snapshot, for: year)
        return snapshot
    }
}

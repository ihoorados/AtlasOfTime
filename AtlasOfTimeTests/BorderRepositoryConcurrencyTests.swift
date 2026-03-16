import Foundation
import Testing
@testable import AtlasOfTime

struct BorderRepositoryConcurrencyTests {
    @Test
    func cacheHitAvoidsDuplicateLoaderExecution() async throws {
        let year = 1900
        let snapshot = makeSnapshot(year: year)
        let loader = CountingBorderSnapshotLoader(snapshots: [year: snapshot])
        let repository = DefaultBorderRepository(
            cache: LRUCache<Int, YearSnapshot>(capacity: 4),
            yearIndexRepository: BorderRepositoryMockYearIndexRepository(index: makeIndex(years: [year])),
            loader: loader
        )

        let first = try await repository.snapshot(for: year)
        let second = try await repository.snapshot(for: year)

        #expect(first.year == year)
        #expect(second.year == year)
        #expect(await loader.loadCount == 1)
        #expect(await loader.loadedYears == [year])
    }

    @Test
    func differentYearsTriggerIndependentLoaderRequests() async throws {
        let years = [1900, 1914]
        let snapshots = Dictionary(uniqueKeysWithValues: years.map { ($0, makeSnapshot(year: $0)) })
        let loader = CountingBorderSnapshotLoader(snapshots: snapshots)
        let repository = DefaultBorderRepository(
            cache: LRUCache<Int, YearSnapshot>(capacity: 4),
            yearIndexRepository: BorderRepositoryMockYearIndexRepository(index: makeIndex(years: years)),
            loader: loader
        )

        let first = try await repository.snapshot(for: years[0])
        let second = try await repository.snapshot(for: years[1])

        #expect(first.year == years[0])
        #expect(second.year == years[1])
        #expect(await loader.loadCount == 2)
        #expect(await loader.loadedYears == years)
    }

    @Test
    func concurrentRequestsForSameYearShareSingleLoaderExecution() async throws {
        let year = 1900
        let snapshot = makeSnapshot(year: year)
        let loader = CountingBorderSnapshotLoader(
            snapshots: [year: snapshot],
            delays: [year: 100_000_000]
        )
        let repository = DefaultBorderRepository(
            cache: LRUCache<Int, YearSnapshot>(capacity: 4),
            yearIndexRepository: BorderRepositoryMockYearIndexRepository(index: makeIndex(years: [year])),
            loader: loader
        )

        async let first = repository.snapshot(for: year)
        async let second = repository.snapshot(for: year)

        let resolved = try await [first, second]

        #expect(resolved.allSatisfy { $0.year == year })
        #expect(await loader.loadCount == 1)
        #expect(await loader.loadedYears == [year])
    }

    private func makeIndex(years: [Int]) -> YearIndex {
        YearIndex(
            minYear: years.min() ?? 0,
            maxYear: years.max() ?? 0,
            availableYears: years,
            filesByYear: Dictionary(uniqueKeysWithValues: years.map { ($0, "years/\($0).geojson.gz") })
        )
    }

    private func makeSnapshot(year: Int) -> YearSnapshot {
        let polygon = GeoPolygon(
            outer: [
                Coordinate(lat: 0, lon: 0),
                Coordinate(lat: 1, lon: 0),
                Coordinate(lat: 1, lon: 1),
                Coordinate(lat: 0, lon: 1),
                Coordinate(lat: 0, lon: 0)
            ],
            holes: []
        )

        return YearSnapshot(year: year, polygons: [polygon])
    }
}

private actor BorderRepositoryMockYearIndexRepository: YearIndexRepository {
    private let index: YearIndex

    init(index: YearIndex) {
        self.index = index
    }

    func load() async throws -> YearIndex {
        index
    }
}

private actor CountingBorderSnapshotLoader: BorderSnapshotLoading {
    private let snapshots: [Int: YearSnapshot]
    private let delays: [Int: UInt64]
    private(set) var loadCount = 0
    private(set) var loadedYears: [Int] = []

    init(snapshots: [Int: YearSnapshot], delays: [Int: UInt64] = [:]) {
        self.snapshots = snapshots
        self.delays = delays
    }

    func loadSnapshot(year: Int, relativePath: String) async throws -> YearSnapshot {
        loadCount += 1
        loadedYears.append(year)

        if let delay = delays[year] {
            try await Task.sleep(nanoseconds: delay)
        }

        guard let snapshot = snapshots[year] else {
            throw AppError.yearUnavailable(year)
        }

        return snapshot
    }
}

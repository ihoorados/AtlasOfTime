import Foundation
import Testing
@testable import AtlasOfTime

struct UseCaseConcurrencyContractTests {
    @Test
    func loadYearIndexRemainsUsableAcrossTaskBoundary() async throws {
        let years = [1900, 1914]
        let useCase = LoadYearIndex(
            repository: ConcurrencyContractYearIndexRepository(index: makeIndex(years: years))
        )

        let loadedIndex = try await Task {
            try await useCase.execute()
        }.value

        #expect(loadedIndex.availableYears == years)
    }

    @Test
    func loadBordersForYearRemainsUsableAcrossTaskBoundary() async throws {
        let year = 1914
        let snapshot = makeSnapshot(year: year)
        let useCase = LoadBordersForYear(
            repository: ConcurrencyContractBorderRepository(snapshots: [year: snapshot])
        )

        let loadedSnapshot = try await Task {
            try await useCase.execute(year: year)
        }.value

        #expect(loadedSnapshot.year == year)
        #expect(loadedSnapshot.polygons == snapshot.polygons)
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

private actor ConcurrencyContractYearIndexRepository: YearIndexRepository {
    private let index: YearIndex

    init(index: YearIndex) {
        self.index = index
    }

    func load() async throws -> YearIndex {
        index
    }
}

private actor ConcurrencyContractBorderRepository: BorderRepository {
    private let snapshots: [Int: YearSnapshot]

    init(snapshots: [Int: YearSnapshot]) {
        self.snapshots = snapshots
    }

    func snapshot(for year: Int) async throws -> YearSnapshot {
        guard let snapshot = snapshots[year] else {
            throw AppError.yearUnavailable(year)
        }

        return snapshot
    }
}

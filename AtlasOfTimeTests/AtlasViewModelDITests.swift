import Foundation
import Testing
@testable import AtlasOfTime

@MainActor
struct AtlasViewModelDITests {
    @Test
    func onAppearLoadsInitialSnapshot() async throws {
        let years = [1900, 1914]
        let index = makeIndex(years: years)
        let snapshots = makeSnapshots(years: years)

        let container = TestAppDIContainer(index: index, snapshots: snapshots)
        let viewModel = container.makeAtlasViewModel()

        viewModel.onAppear()

        try await waitUntil { viewModel.renderSnapshot?.year == 1900 }

        #expect(viewModel.availableYears == years)
        #expect(viewModel.displayYear == 1900)
        #expect(viewModel.renderSnapshot?.year == 1900)
    }

    @Test
    func onYearChangedUpdatesDisplayedYearImmediately() async throws {
        let years = [1900, 1914]
        let index = makeIndex(years: years)
        let snapshots = makeSnapshots(years: years)

        let container = TestAppDIContainer(index: index, snapshots: snapshots)
        let viewModel = container.makeAtlasViewModel()

        viewModel.onAppear()
        try await waitUntil { viewModel.renderSnapshot?.year == 1900 }

        viewModel.onYearChanged(year: 1914)
        #expect(viewModel.displayYear == 1914)

        try await waitUntil { viewModel.renderSnapshot?.year == 1914 }
        #expect(viewModel.renderSnapshot?.year == 1914)
    }

    @Test
    func latestYearRequestWinsDuringScrubbing() async throws {
        let years = [1900, 1914, 1920]
        let index = makeIndex(years: years)
        let snapshots = makeSnapshots(years: years)
        let delays: [Int: UInt64] = [
            1914: 250_000_000,
            1920: 10_000_000
        ]

        let container = TestAppDIContainer(index: index, snapshots: snapshots, delays: delays)
        let viewModel = container.makeAtlasViewModel()

        viewModel.onAppear()
        try await waitUntil { viewModel.renderSnapshot?.year == 1900 }

        viewModel.onYearChanged(year: 1914)
        viewModel.onYearChanged(year: 1920)

        try await waitUntil { viewModel.renderSnapshot?.year == 1920 }
        #expect(viewModel.renderSnapshot?.year == 1920)

        try await Task.sleep(nanoseconds: 350_000_000)
        #expect(viewModel.renderSnapshot?.year == 1920)
    }

    private func makeIndex(years: [Int]) -> YearIndex {
        YearIndex(
            minYear: years.min() ?? 0,
            maxYear: years.max() ?? 0,
            availableYears: years,
            filesByYear: Dictionary(uniqueKeysWithValues: years.map { ($0, "years/\($0).geojson.gz") })
        )
    }

    private func makeSnapshots(years: [Int]) -> [Int: YearSnapshot] {
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
        return Dictionary(uniqueKeysWithValues: years.map { year in
            (year, YearSnapshot(year: year, polygons: [polygon]))
        })
    }

    private func waitUntil(
        timeoutNanoseconds: UInt64 = 1_000_000_000,
        pollNanoseconds: UInt64 = 10_000_000,
        condition: @escaping @MainActor () -> Bool
    ) async throws {
        let start = ContinuousClock.now
        let timeout = Duration.nanoseconds(Int64(timeoutNanoseconds))

        while !condition() {
            if ContinuousClock.now - start > timeout {
                Issue.record("Timed out waiting for condition")
                throw AppError.unknown("Test timeout")
            }
            try await Task.sleep(nanoseconds: pollNanoseconds)
        }
    }
}

@MainActor
private struct TestAppDIContainer: AtlasDIProviding {
    private let featureContainer: AtlasFeatureDIContainer

    init(
        index: YearIndex,
        snapshots: [Int: YearSnapshot],
        delays: [Int: UInt64] = [:]
    ) {
        let yearIndexRepository = MockYearIndexRepository(index: index)
        let borderRepository = MockBorderRepository(snapshots: snapshots, delays: delays)

        let domainContainer = DomainDIContainer(
            yearIndexRepository: yearIndexRepository,
            borderRepository: borderRepository
        )

        self.featureContainer = AtlasFeatureDIContainer(
            loadYearIndex: domainContainer.makeLoadYearIndex(),
            loadBordersForYear: domainContainer.makeLoadBordersForYear(),
            debounceNanoseconds: 0
        )
    }

    func makeAtlasViewModel() -> AtlasViewModel {
        featureContainer.makeAtlasViewModel()
    }
}

private actor MockYearIndexRepository: YearIndexRepository {
    private let index: YearIndex

    init(index: YearIndex) {
        self.index = index
    }

    func load() async throws -> YearIndex {
        index
    }
}

private actor MockBorderRepository: BorderRepository {
    private let snapshots: [Int: YearSnapshot]
    private let delays: [Int: UInt64]

    init(snapshots: [Int: YearSnapshot], delays: [Int: UInt64]) {
        self.snapshots = snapshots
        self.delays = delays
    }

    func snapshot(for year: Int) async throws -> YearSnapshot {
        if let delay = delays[year] {
            try await Task.sleep(nanoseconds: delay)
        }

        guard let snapshot = snapshots[year] else {
            throw AppError.yearUnavailable(year)
        }
        return snapshot
    }
}

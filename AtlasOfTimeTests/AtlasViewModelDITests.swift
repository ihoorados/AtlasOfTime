import Foundation
import Testing
import CoreAtlasDomain
@testable import AtlasOfTime

@MainActor
struct AtlasViewModelDITests {
    @Test
    func onAppearLoadsInitialSnapshot() async throws {
        let years = [1900, 1914]
        let index = makeIndex(years: years)
        let snapshots = makeSnapshots(years: years)
        let pois = makePOIs(years: years)

        let container = TestAppDIContainer(index: index, snapshots: snapshots, pois: pois)
        let viewModel = container.makeAtlasViewModel()

        viewModel.onAppear()

        try await waitUntil { viewModel.renderSnapshot?.year == 1900 }
        try await waitUntil { viewModel.pointsOfInterest == pois[1900] }

        #expect(viewModel.availableYears == years)
        #expect(viewModel.displayYear == 1900)
        #expect(viewModel.renderSnapshot?.year == 1900)
        #expect(viewModel.pointsOfInterest == pois[1900])
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
    func onYearChangedLoadsPOIsForSelectedYear() async throws {
        let years = [1900, 1914]
        let index = makeIndex(years: years)
        let snapshots = makeSnapshots(years: years)
        let pois = makePOIs(years: years)

        let container = TestAppDIContainer(index: index, snapshots: snapshots, pois: pois)
        let viewModel = container.makeAtlasViewModel()

        viewModel.onAppear()
        try await waitUntil { viewModel.pointsOfInterest == pois[1900] }

        viewModel.onYearChanged(year: 1914)

        #expect(viewModel.pointsOfInterest.isEmpty)
        try await waitUntil { viewModel.renderSnapshot?.year == 1914 }
        try await waitUntil { viewModel.pointsOfInterest == pois[1914] }
        #expect(viewModel.poiErrorMessage == nil)
    }

    @Test
    func poiFailureDoesNotClearLoadedSnapshot() async throws {
        let years = [1900]
        let index = makeIndex(years: years)
        let snapshots = makeSnapshots(years: years)
        let poiRepository = MockPOIRepository(failingYears: [1900])
        let container = TestAppDIContainer(
            index: index,
            borderRepository: MockBorderRepository(snapshots: snapshots, delays: [:]),
            poiRepository: poiRepository
        )
        let viewModel = container.makeAtlasViewModel()

        viewModel.onAppear()

        try await waitUntil { viewModel.renderSnapshot?.year == 1900 }
        try await waitUntil { viewModel.poiErrorMessage != nil }
        #expect(viewModel.renderSnapshot?.year == 1900)
        #expect(viewModel.pointsOfInterest.isEmpty)
        #expect(viewModel.errorMessage == nil)
    }

    @Test
    func selectPOIOnlyAcceptsVisiblePOIs() async throws {
        let years = [1900]
        let index = makeIndex(years: years)
        let snapshots = makeSnapshots(years: years)
        let pois = makePOIs(years: years)

        let container = TestAppDIContainer(index: index, snapshots: snapshots, pois: pois)
        let viewModel = container.makeAtlasViewModel()

        viewModel.onAppear()
        try await waitUntil { viewModel.pointsOfInterest == pois[1900] }

        viewModel.selectCountry(id: "year-1900-unattributed")
        #expect(viewModel.selectedCountryID == "year-1900-unattributed")

        viewModel.selectPOI(id: pois[1900]?.first?.id)
        #expect(viewModel.selectedPOI == pois[1900]?.first)
        #expect(viewModel.selectedPOISourceCount == 1)
        #expect(viewModel.selectedCountryID == nil)

        viewModel.selectPOI(id: "missing-poi")
        #expect(viewModel.selectedPOI == nil)

        viewModel.selectPOI(id: pois[1900]?.first?.id)
        viewModel.selectCountry(id: "year-1900-unattributed")
        #expect(viewModel.selectedPOI == nil)
        #expect(viewModel.selectedCountryID == "year-1900-unattributed")
    }

    @Test
    func latestYearRequestWinsDuringScrubbing() async throws {
        let years = [1900, 1914, 1920]
        let index = makeIndex(years: years)
        let snapshots = makeSnapshots(years: years)
        let firstLoadStarted = AsyncSignal()
        let firstLoadReleased = AsyncGate()
        let firstLoadFinished = AsyncSignal()
        let borderRepository = SignalingBorderRepository(
            snapshots: snapshots,
            startedSignals: [1914: firstLoadStarted],
            finishSignals: [1914: firstLoadFinished],
            gates: [1914: firstLoadReleased]
        )

        let container = TestAppDIContainer(
            index: index,
            borderRepository: borderRepository
        )
        let viewModel = container.makeAtlasViewModel()

        viewModel.onAppear()
        try await waitUntil { viewModel.renderSnapshot?.year == 1900 }

        viewModel.onYearChanged(year: 1914)
        await firstLoadStarted.wait()
        viewModel.onYearChanged(year: 1920)

        try await waitUntil { viewModel.renderSnapshot?.year == 1920 }
        #expect(viewModel.renderSnapshot?.year == 1920)

        await firstLoadReleased.open()
        await firstLoadFinished.wait()
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

    private func makePOIs(years: [Int]) -> [Int: [HistoricalPOI]] {
        Dictionary(uniqueKeysWithValues: years.map { year in
            (
                year,
                [
                    HistoricalPOI(
                        id: "poi-\(year)",
                        year: year,
                        title: "Event \(year)",
                        summary: "Important event in \(year).",
                        coordinate: Coordinate(lat: 1, lon: 1),
                        category: .politicalEvent,
                        confidence: .high,
                        sourceReferences: [
                            HistoricalSourceReference(
                                id: "source-\(year)",
                                title: "Source \(year)"
                            )
                        ]
                    )
                ]
            )
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
private struct TestAppDIContainer {
    private let featureContainer: AtlasFeatureDIContainer

    init(
        index: YearIndex,
        snapshots: [Int: YearSnapshot],
        pois: [Int: [HistoricalPOI]] = [:],
        delays: [Int: UInt64] = [:]
    ) {
        let yearIndexRepository = MockYearIndexRepository(index: index)
        let borderRepository = MockBorderRepository(snapshots: snapshots, delays: delays)
        let poiRepository = MockPOIRepository(pois: pois)

        let domainContainer = DomainDIContainer(
            yearIndexRepository: yearIndexRepository,
            borderRepository: borderRepository,
            poiRepository: poiRepository
        )

        self.featureContainer = AtlasFeatureDIContainer(
            loadYearIndex: domainContainer.makeLoadYearIndex(),
            loadBordersForYear: domainContainer.makeLoadBordersForYear(),
            loadPOIsForYear: domainContainer.makeLoadPOIsForYear(),
            debounceNanoseconds: 0
        )
    }

    init(
        index: YearIndex,
        borderRepository: any BorderRepository,
        poiRepository: any POIRepository = MockPOIRepository()
    ) {
        let yearIndexRepository = MockYearIndexRepository(index: index)

        let domainContainer = DomainDIContainer(
            yearIndexRepository: yearIndexRepository,
            borderRepository: borderRepository,
            poiRepository: poiRepository
        )

        self.featureContainer = AtlasFeatureDIContainer(
            loadYearIndex: domainContainer.makeLoadYearIndex(),
            loadBordersForYear: domainContainer.makeLoadBordersForYear(),
            loadPOIsForYear: domainContainer.makeLoadPOIsForYear(),
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
            throw AtlasDomainError.yearUnavailable(year)
        }
        return snapshot
    }
}

private actor MockPOIRepository: POIRepository {
    private let pois: [Int: [HistoricalPOI]]
    private let failingYears: Set<Int>

    init(
        pois: [Int: [HistoricalPOI]] = [:],
        failingYears: Set<Int> = []
    ) {
        self.pois = pois
        self.failingYears = failingYears
    }

    func pointsOfInterest(for year: Int) async throws -> [HistoricalPOI] {
        if failingYears.contains(year) {
            throw AtlasDomainError.yearUnavailable(year)
        }

        return pois[year] ?? []
    }
}

private actor SignalingBorderRepository: BorderRepository {
    private let snapshots: [Int: YearSnapshot]
    private let startedSignals: [Int: AsyncSignal]
    private let finishSignals: [Int: AsyncSignal]
    private let gates: [Int: AsyncGate]

    init(
        snapshots: [Int: YearSnapshot],
        startedSignals: [Int: AsyncSignal] = [:],
        finishSignals: [Int: AsyncSignal] = [:],
        gates: [Int: AsyncGate] = [:]
    ) {
        self.snapshots = snapshots
        self.startedSignals = startedSignals
        self.finishSignals = finishSignals
        self.gates = gates
    }

    func snapshot(for year: Int) async throws -> YearSnapshot {
        if let startedSignal = startedSignals[year] {
            await startedSignal.signal()
        }

        do {
            if let gate = gates[year] {
                await gate.wait()
            }

            try Task.checkCancellation()

            guard let snapshot = snapshots[year] else {
                throw AtlasDomainError.yearUnavailable(year)
            }

            if let finishSignal = finishSignals[year] {
                await finishSignal.signal()
            }

            return snapshot
        } catch {
            if let finishSignal = finishSignals[year] {
                await finishSignal.signal()
            }
            throw error
        }
    }
}

private actor AsyncSignal {
    private var isSignaled = false
    private var continuations: [CheckedContinuation<Void, Never>] = []

    func wait() async {
        if isSignaled {
            return
        }

        await withCheckedContinuation { continuation in
            continuations.append(continuation)
        }
    }

    func signal() {
        guard !isSignaled else {
            return
        }

        isSignaled = true
        let pendingContinuations = continuations
        continuations.removeAll()
        for continuation in pendingContinuations {
            continuation.resume()
        }
    }
}

private actor AsyncGate {
    private var isOpen = false
    private var continuations: [CheckedContinuation<Void, Never>] = []

    func wait() async {
        if isOpen {
            return
        }

        await withCheckedContinuation { continuation in
            continuations.append(continuation)
        }
    }

    func open() {
        guard !isOpen else {
            return
        }

        isOpen = true
        let pendingContinuations = continuations
        continuations.removeAll()
        for continuation in pendingContinuations {
            continuation.resume()
        }
    }
}

import Combine
import Foundation
import CoreAtlasMap
import CoreAtlasDomain

@MainActor
final class AtlasViewModel: ObservableObject {
    @Published var availableYears: [Int] = []
    @Published var displayYear: Int = 0
    @Published var renderSnapshot: YearSnapshot?
    @Published private(set) var mapSnapshot: AtlasMapSnapshot?
    @Published private(set) var visibleSnapshots: [HistoricalCountrySnapshot] = []
    @Published private(set) var pointsOfInterest: [HistoricalPOI] = []
    @Published private(set) var selectedCountryID: String?
    @Published private(set) var selectedPOIID: String?
    @Published var errorMessage: String?
    @Published private(set) var poiErrorMessage: String?
    @Published var isLoading: Bool = false
    @Published var showsPointsOfInterest: Bool = true {
        didSet {
            guard oldValue != showsPointsOfInterest else { return }
            if !showsPointsOfInterest {
                selectedPOIID = nil
            }
            refreshMapSnapshot()
        }
    }

    private let yearLoader: AtlasYearLoader
    private let mapSnapshotMapper: AtlasMapSnapshotMapper

    init(
        loadYearIndex: LoadYearIndex,
        loadBordersForYear: LoadBordersForYear,
        loadPOIsForYear: LoadPOIsForYear,
        debouncer: Debouncer,
        debounceNanoseconds: UInt64 = 150_000_000,
        mapSnapshotMapper: AtlasMapSnapshotMapper = AtlasMapSnapshotMapper()
    ) {
        self.yearLoader = AtlasYearLoader(
            loadYearIndex: loadYearIndex,
            loadBordersForYear: loadBordersForYear,
            loadPOIsForYear: loadPOIsForYear,
            debouncer: debouncer,
            debounceNanoseconds: debounceNanoseconds
        )
        self.mapSnapshotMapper = mapSnapshotMapper
        self.yearLoader.bind(self)
    }

    func onAppear() {
        yearLoader.onAppear()
    }

    func onYearChanged(year: Int) {
        guard !availableYears.isEmpty else { return }

        let snappedYear = nearestAvailableYear(to: year)
        displayYear = snappedYear
        selectedCountryID = nil
        selectedPOIID = nil
        pointsOfInterest = []
        refreshMapSnapshot()
        poiErrorMessage = nil
        yearLoader.requestYear(snappedYear)
    }

    var selectedCountrySnapshot: HistoricalCountrySnapshot? {
        guard let selectedCountryID else { return nil }
        return visibleSnapshots.first { $0.id == selectedCountryID }
    }

    var selectedPrimaryExtent: HistoricalExtent? {
        selectedCountrySnapshot?.extents.first
    }

    var selectedPOI: HistoricalPOI? {
        guard let selectedPOIID else { return nil }
        return pointsOfInterest.first { $0.id == selectedPOIID }
    }

    var selectedPOIConfidenceText: LocalizedStringResource {
        switch selectedPOI?.confidence ?? .unknown {
        case .high:
            AppStrings.Home.confidenceHigh
        case .medium:
            AppStrings.Home.confidenceMedium
        case .low:
            AppStrings.Home.confidenceLow
        case .unknown:
            AppStrings.Home.confidenceUnknown
        }
    }

    var selectedPOISourceCount: Int {
        selectedPOI?.sourceReferences.count ?? 0
    }

    var selectedCountryBorderConfidenceText: LocalizedStringResource {
        switch selectedPrimaryExtent?.borderConfidence ?? .unknown {
        case .high:
            AppStrings.Home.confidenceHigh
        case .medium:
            AppStrings.Home.confidenceMedium
        case .low:
            AppStrings.Home.confidenceLow
        case .unknown:
            AppStrings.Home.confidenceUnknown
        }
    }

    var selectedCountrySourceCount: Int {
        let extentReferences = selectedPrimaryExtent?.sourceReferences ?? []
        let snapshotReferences = selectedCountrySnapshot?.sourceReferences ?? []
        return Set(extentReferences.map(\.id) + snapshotReferences.map(\.id)).count
    }

    func selectCountry(id: String?) {
        guard let id else {
            selectedCountryID = nil
            return
        }

        selectedCountryID = visibleSnapshots.contains(where: { $0.id == id }) ? id : nil
        if selectedCountryID != nil {
            selectedPOIID = nil
        }
    }

    func selectPOI(id: String?) {
        guard let id else {
            selectedPOIID = nil
            return
        }

        selectedPOIID = pointsOfInterest.contains(where: { $0.id == id }) ? id : nil
        if selectedPOIID != nil {
            selectedCountryID = nil
        }
    }

    private func nearestAvailableYear(to year: Int) -> Int {
        guard let first = availableYears.first else { return year }

        var nearest = first
        var nearestDistance = abs(first - year)

        for candidate in availableYears {
            let distance = abs(candidate - year)
            if distance < nearestDistance {
                nearestDistance = distance
                nearest = candidate
            }
        }

        return nearest
    }

    private func refreshMapSnapshot() {
        let nextSnapshot = mapSnapshotMapper.makeSnapshot(
            from: renderSnapshot,
            pointsOfInterest: showsPointsOfInterest ? pointsOfInterest : []
        )
        if mapSnapshot != nextSnapshot {
            mapSnapshot = nextSnapshot
        }
    }
}

@MainActor
private protocol AtlasYearLoadingOutput: AnyObject {
    func setLoading(_ isLoading: Bool)
    func applyIndex(_ index: YearIndex, initialYear: Int)
    func applySnapshot(_ snapshot: YearSnapshot)
    func applyPOIs(_ pointsOfInterest: [HistoricalPOI])
    func applyPOIFailure(_ error: AppError)
    func applyBootstrapFailure(_ error: AppError)
    func applySnapshotFailure(_ error: AppError)
}

@MainActor
extension AtlasViewModel: AtlasYearLoadingOutput {
    fileprivate func setLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }

    fileprivate func applyIndex(_ index: YearIndex, initialYear: Int) {
        availableYears = index.availableYears.sorted()
        displayYear = initialYear
        renderSnapshot = nil
        mapSnapshot = nil
        visibleSnapshots = []
        pointsOfInterest = []
        selectedCountryID = nil
        selectedPOIID = nil
        errorMessage = nil
        poiErrorMessage = nil
    }

    fileprivate func applySnapshot(_ snapshot: YearSnapshot) {
        renderSnapshot = snapshot
        visibleSnapshots = snapshot.snapshots
        refreshMapSnapshot()
        if let selectedCountryID,
           snapshot.snapshots.contains(where: { $0.id == selectedCountryID }) {
            self.selectedCountryID = selectedCountryID
        } else {
            selectedCountryID = nil
        }
        errorMessage = nil
    }

    fileprivate func applyPOIs(_ pointsOfInterest: [HistoricalPOI]) {
        self.pointsOfInterest = pointsOfInterest
        refreshMapSnapshot()
        if let selectedPOIID,
           pointsOfInterest.contains(where: { $0.id == selectedPOIID }) {
            self.selectedPOIID = selectedPOIID
        } else {
            selectedPOIID = nil
        }
        poiErrorMessage = nil
    }

    fileprivate func applyPOIFailure(_ error: AppError) {
        pointsOfInterest = []
        selectedPOIID = nil
        refreshMapSnapshot()
        poiErrorMessage = error.userMessage
    }

    fileprivate func applyBootstrapFailure(_ error: AppError) {
        renderSnapshot = nil
        mapSnapshot = nil
        visibleSnapshots = []
        pointsOfInterest = []
        selectedCountryID = nil
        selectedPOIID = nil
        errorMessage = error.userMessage
        poiErrorMessage = nil
    }

    fileprivate func applySnapshotFailure(_ error: AppError) {
        renderSnapshot = nil
        mapSnapshot = nil
        visibleSnapshots = []
        pointsOfInterest = []
        selectedCountryID = nil
        selectedPOIID = nil
        errorMessage = error.userMessage
        poiErrorMessage = nil
    }
}

@MainActor
private final class AtlasYearLoader {
    private weak var output: (any AtlasYearLoadingOutput)?

    private let loadYearIndex: LoadYearIndex
    private let loadBordersForYear: LoadBordersForYear
    private let loadPOIsForYear: LoadPOIsForYear
    private let debouncer: Debouncer
    private let debounceNanoseconds: UInt64

    private var didAppear = false
    private var latestRequestToken: UInt64 = 0
    private var requestCounter: UInt64 = 0
    private var bootstrapTask: Task<Void, Never>?
    private var loadTask: Task<Void, Never>?

    init(
        loadYearIndex: LoadYearIndex,
        loadBordersForYear: LoadBordersForYear,
        loadPOIsForYear: LoadPOIsForYear,
        debouncer: Debouncer,
        debounceNanoseconds: UInt64
    ) {
        self.loadYearIndex = loadYearIndex
        self.loadBordersForYear = loadBordersForYear
        self.loadPOIsForYear = loadPOIsForYear
        self.debouncer = debouncer
        self.debounceNanoseconds = debounceNanoseconds
    }

    func bind(_ output: any AtlasYearLoadingOutput) {
        self.output = output
    }

    func onAppear() {
        guard !didAppear else { return }
        didAppear = true

        bootstrapTask?.cancel()
        bootstrapTask = Task { [weak self] in
            await self?.bootstrap()
        }
    }

    func requestYear(_ year: Int) {
        let token = nextRequestToken()

        Task { [debouncer, debounceNanoseconds] in
            await debouncer.schedule(token: token, delayNanoseconds: debounceNanoseconds) { [weak self] in
                await self?.replaceLoadTask(for: year, token: token)
            }
        }
    }

    deinit {
        bootstrapTask?.cancel()
        loadTask?.cancel()
        Task { [debouncer] in
            await debouncer.cancelAll()
        }
    }

    private func bootstrap() async {
        output?.setLoading(true)

        do {
            let index = try await loadYearIndex.execute()
            let years = index.availableYears.sorted()

            guard let initialYear = years.first else {
                throw AppError.invalidIndexFormat("availableYears is empty.")
            }

            output?.applyIndex(index, initialYear: initialYear)
            output?.setLoading(false)
            loadImmediately(for: initialYear)
        } catch {
            output?.applyBootstrapFailure(AppError.wrap(error))
            output?.setLoading(false)
        }
    }

    private func loadImmediately(for year: Int) {
        let token = nextRequestToken()
        replaceLoadTask(for: year, token: token)
    }

    private func replaceLoadTask(for year: Int, token: UInt64) {
        guard token == latestRequestToken else { return }

        loadTask?.cancel()
        loadTask = Task { [weak self] in
            await self?.executeLoad(for: year, token: token)
        }
    }

    private func executeLoad(for year: Int, token: UInt64) async {
        guard token == latestRequestToken else { return }
        output?.setLoading(true)

        do {
            async let poiResult = loadPOIsResult(for: year)
            let snapshot = try await loadBordersForYear.execute(year: year)
            try Task.checkCancellation()

            guard token == latestRequestToken else { return }
            output?.applySnapshot(snapshot)
            output?.setLoading(false)

            let loadedPOIs = await poiResult
            guard token == latestRequestToken else { return }
            switch loadedPOIs {
            case .success(let pointsOfInterest):
                output?.applyPOIs(pointsOfInterest)
            case .failure(let error):
                output?.applyPOIFailure(error)
            }
        } catch is CancellationError {
            // Newer request replaced this one.
        } catch {
            guard token == latestRequestToken else { return }
            output?.applySnapshotFailure(AppError.wrap(error))
            output?.setLoading(false)
        }

        if token == latestRequestToken {
            output?.setLoading(false)
        }
    }

    private func loadPOIsResult(for year: Int) async -> Result<[HistoricalPOI], AppError> {
        do {
            let pointsOfInterest = try await loadPOIsForYear.execute(year: year)
            try Task.checkCancellation()
            return .success(pointsOfInterest)
        } catch is CancellationError {
            return .failure(.unknown("POI loading was cancelled."))
        } catch {
            return .failure(AppError.wrap(error))
        }
    }

    private func nextRequestToken() -> UInt64 {
        requestCounter &+= 1
        latestRequestToken = requestCounter
        return requestCounter
    }
}

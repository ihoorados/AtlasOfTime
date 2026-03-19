import Combine
import Foundation

@MainActor
final class AtlasViewModel: ObservableObject {
    @Published var availableYears: [Int] = []
    @Published var displayYear: Int = 0
    @Published var renderSnapshot: YearSnapshot?
    @Published private(set) var visibleSnapshots: [HistoricalCountrySnapshot] = []
    @Published private(set) var selectedCountryID: String?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private let yearLoader: AtlasYearLoader

    init(
        loadYearIndex: LoadYearIndex,
        loadBordersForYear: LoadBordersForYear,
        debouncer: Debouncer,
        debounceNanoseconds: UInt64 = 150_000_000
    ) {
        self.yearLoader = AtlasYearLoader(
            loadYearIndex: loadYearIndex,
            loadBordersForYear: loadBordersForYear,
            debouncer: debouncer,
            debounceNanoseconds: debounceNanoseconds
        )
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
        yearLoader.requestYear(snappedYear)
    }

    var selectedCountrySnapshot: HistoricalCountrySnapshot? {
        guard let selectedCountryID else { return nil }
        return visibleSnapshots.first { $0.id == selectedCountryID }
    }

    var selectedPrimaryExtent: HistoricalExtent? {
        selectedCountrySnapshot?.extents.first
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
}

@MainActor
private protocol AtlasYearLoadingOutput: AnyObject {
    func setLoading(_ isLoading: Bool)
    func applyIndex(_ index: YearIndex, initialYear: Int)
    func applySnapshot(_ snapshot: YearSnapshot)
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
        visibleSnapshots = []
        selectedCountryID = nil
        errorMessage = nil
    }

    fileprivate func applySnapshot(_ snapshot: YearSnapshot) {
        renderSnapshot = snapshot
        visibleSnapshots = snapshot.snapshots
        if let selectedCountryID,
           snapshot.snapshots.contains(where: { $0.id == selectedCountryID }) {
            self.selectedCountryID = selectedCountryID
        } else {
            selectedCountryID = nil
        }
        errorMessage = nil
    }

    fileprivate func applyBootstrapFailure(_ error: AppError) {
        renderSnapshot = nil
        visibleSnapshots = []
        selectedCountryID = nil
        errorMessage = error.userMessage
    }

    fileprivate func applySnapshotFailure(_ error: AppError) {
        renderSnapshot = nil
        visibleSnapshots = []
        selectedCountryID = nil
        errorMessage = error.userMessage
    }
}

@MainActor
private final class AtlasYearLoader {
    private weak var output: (any AtlasYearLoadingOutput)?

    private let loadYearIndex: LoadYearIndex
    private let loadBordersForYear: LoadBordersForYear
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
        debouncer: Debouncer,
        debounceNanoseconds: UInt64
    ) {
        self.loadYearIndex = loadYearIndex
        self.loadBordersForYear = loadBordersForYear
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
            let snapshot = try await loadBordersForYear.execute(year: year)
            try Task.checkCancellation()

            guard token == latestRequestToken else { return }
            output?.applySnapshot(snapshot)
        } catch is CancellationError {
            // Newer request replaced this one.
        } catch {
            guard token == latestRequestToken else { return }
            output?.applySnapshotFailure(AppError.wrap(error))
        }

        if token == latestRequestToken {
            output?.setLoading(false)
        }
    }

    private func nextRequestToken() -> UInt64 {
        requestCounter &+= 1
        latestRequestToken = requestCounter
        return requestCounter
    }
}

import Combine
import Foundation

@MainActor
final class AtlasViewModel: ObservableObject {
    @Published var availableYears: [Int] = []
    @Published var displayYear: Int = 0
    @Published var renderSnapshot: YearSnapshot?
    @Published private(set) var visibleCountries: [HistoricalCountry] = []
    @Published private(set) var selectedCountryID: String?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

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
        debounceNanoseconds: UInt64 = 150_000_000
    ) {
        self.loadYearIndex = loadYearIndex
        self.loadBordersForYear = loadBordersForYear
        self.debouncer = debouncer
        self.debounceNanoseconds = debounceNanoseconds
    }

    func onAppear() {
        guard !didAppear else { return }
        didAppear = true

        bootstrapTask?.cancel()
        bootstrapTask = Task { [weak self] in
            await self?.bootstrap()
        }
    }

    func onYearChanged(year: Int) {
        guard !availableYears.isEmpty else { return }

        let snappedYear = nearestAvailableYear(to: year)
        displayYear = snappedYear
        selectedCountryID = nil
        scheduleDebouncedLoad(for: snappedYear)
    }

    var selectedCountry: HistoricalCountry? {
        guard let selectedCountryID else { return nil }
        return visibleCountries.first { $0.id == selectedCountryID }
    }

    func selectCountry(id: String?) {
        guard let id else {
            selectedCountryID = nil
            return
        }

        selectedCountryID = visibleCountries.contains(where: { $0.id == id }) ? id : nil
    }

    private func bootstrap() async {
        isLoading = true

        do {
            let index = try await loadYearIndex.execute()

            let years = index.availableYears.sorted()
            guard let initialYear = years.first else {
                throw AppError.invalidIndexFormat("availableYears is empty.")
            }

            availableYears = years
            displayYear = initialYear
            renderSnapshot = nil
            visibleCountries = []
            selectedCountryID = nil
            errorMessage = nil
            isLoading = false

            loadImmediately(for: initialYear)
        } catch {
            renderSnapshot = nil
            visibleCountries = []
            selectedCountryID = nil
            isLoading = false
            errorMessage = AppError.wrap(error).userMessage
        }
    }

    private func scheduleDebouncedLoad(for year: Int) {
        let token = nextRequestToken()

        Task { [debouncer, debounceNanoseconds] in
            await debouncer.schedule(token: token, delayNanoseconds: debounceNanoseconds) { [weak self] in
                await self?.replaceLoadTask(for: year, token: token)
            }
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
        isLoading = true

        do {
            let snapshot = try await loadBordersForYear.execute(year: year)
            try Task.checkCancellation()

            guard token == latestRequestToken else { return }
            renderSnapshot = snapshot
            visibleCountries = snapshot.countries
            if let selectedCountryID,
               snapshot.countries.contains(where: { $0.id == selectedCountryID }) {
                self.selectedCountryID = selectedCountryID
            } else {
                selectedCountryID = nil
            }
            errorMessage = nil
        } catch is CancellationError {
            // Newer request replaced this one.
        } catch {
            guard token == latestRequestToken else { return }
            renderSnapshot = nil
            visibleCountries = []
            selectedCountryID = nil
            errorMessage = AppError.wrap(error).userMessage
        }

        if token == latestRequestToken {
            isLoading = false
        }
    }

    private func nextRequestToken() -> UInt64 {
        requestCounter &+= 1
        latestRequestToken = requestCounter
        return requestCounter
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

    deinit {
        bootstrapTask?.cancel()
        loadTask?.cancel()
        Task { [debouncer] in
            await debouncer.cancelAll()
        }
    }
}

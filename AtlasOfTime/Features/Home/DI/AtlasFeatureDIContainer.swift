import Foundation

// Atlas feature container: assembles feature-level presentation objects.
@MainActor
final class AtlasFeatureDIContainer {
    private let loadYearIndex: LoadYearIndex
    private let loadBordersForYear: LoadBordersForYear
    private let generateCountrySummary: GenerateCountrySummary
    private let debounceNanoseconds: UInt64

    init(
        loadYearIndex: LoadYearIndex,
        loadBordersForYear: LoadBordersForYear,
        generateCountrySummary: GenerateCountrySummary,
        debounceNanoseconds: UInt64 = 150_000_000
    ) {
        self.loadYearIndex = loadYearIndex
        self.loadBordersForYear = loadBordersForYear
        self.generateCountrySummary = generateCountrySummary
        self.debounceNanoseconds = debounceNanoseconds
    }

    func makeAtlasViewModel() -> AtlasViewModel {
        AtlasViewModel(
            loadYearIndex: loadYearIndex,
            loadBordersForYear: loadBordersForYear,
            debouncer: Debouncer(),
            debounceNanoseconds: debounceNanoseconds
        )
    }

    func makeCountryDetailViewModel(
        snapshot: HistoricalCountrySnapshot
    ) -> CountryDetailViewModel {
        CountryDetailViewModel(
            snapshot: snapshot,
            generateCountrySummary: generateCountrySummary
        )
    }

    func makeCountryDetailScene(
        snapshot: HistoricalCountrySnapshot
    ) -> CountryDetailScene {
        CountryDetailScene(
            viewModel: makeCountryDetailViewModel(snapshot: snapshot)
        )
    }
}

import Foundation

@MainActor
final class CountryDetailFeatureDIContainer {
    private let generateCountrySummary: GenerateCountrySummary

    init(generateCountrySummary: GenerateCountrySummary) {
        self.generateCountrySummary = generateCountrySummary
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

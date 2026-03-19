import Foundation

enum HomeRoute: Hashable {
    case countryDetail(CountryDetailContext)
}

extension HomeRoute {
    struct CountryDetailContext: Hashable, Sendable {
        let snapshot: HistoricalCountrySnapshot

        init(snapshot: HistoricalCountrySnapshot) {
            self.snapshot = snapshot
        }
    }
}

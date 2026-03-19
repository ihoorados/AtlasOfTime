import Foundation

@MainActor
struct HomeRouteResolver {
    func snapshot(
        for route: HomeRoute,
        visibleSnapshots: [HistoricalCountrySnapshot]
    ) -> HistoricalCountrySnapshot? {
        switch route {
        case let .countryDetail(countryID):
            visibleSnapshots.first { $0.id == countryID }
        }
    }
}

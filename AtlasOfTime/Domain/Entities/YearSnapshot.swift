import Foundation

struct YearSnapshot: Sendable {
    let year: Int
    let countries: [HistoricalCountry]

    var polygons: [GeoPolygon] {
        countries.flatMap(\.polygons)
    }

    init(year: Int, countries: [HistoricalCountry]) {
        self.year = year
        self.countries = countries
    }

    init(year: Int, polygons: [GeoPolygon]) {
        self.year = year
        self.countries = [
            HistoricalCountry(
                id: "year-\(year)-unattributed",
                displayName: "Unattributed Borders",
                polygons: polygons
            )
        ]
    }
}

import Foundation

struct YearSnapshot: Sendable {
    let year: Int
    let snapshots: [HistoricalCountrySnapshot]

    var countries: [HistoricalCountry] {
        snapshots.map(HistoricalCountry.init(snapshot:))
    }

    var polygons: [GeoPolygon] {
        snapshots.flatMap { snapshot in
            snapshot.extents.flatMap(\.polygons)
        }
    }

    init(year: Int, snapshots: [HistoricalCountrySnapshot]) {
        self.year = year
        self.snapshots = snapshots
    }

    init(year: Int, countries: [HistoricalCountry]) {
        self.year = year
        self.snapshots = countries.map { country in
            HistoricalCountrySnapshot(
                id: country.id,
                entityID: country.id,
                year: year,
                displayName: country.displayName,
                shortDisplayName: country.shortName,
                formalName: nil,
                nameConfidence: .unknown,
                extents: [
                    HistoricalExtent(
                        id: "\(country.id)-extent",
                        extentType: .control,
                        borderModel: HistoricalExtent.defaultBorderModel(for: country.borderPrecision),
                        borderPrecisionRank: country.borderPrecision,
                        borderConfidence: HistoricalExtent.defaultBorderConfidence(for: country.borderPrecision),
                        polygons: country.polygons,
                        sourceReferences: HistoricalSourceReference.defaultReferences(for: country.infoURL)
                    )
                ],
                sourceReferences: HistoricalSourceReference.defaultReferences(for: country.infoURL)
            )
        }
    }

    init(year: Int, polygons: [GeoPolygon]) {
        self.year = year
        self.snapshots = [
            HistoricalCountrySnapshot(
                id: "year-\(year)-unattributed",
                entityID: "year-\(year)-unattributed",
                year: year,
                displayName: "Unattributed Borders",
                nameConfidence: .unknown,
                extents: [
                    HistoricalExtent(
                        id: "year-\(year)-unattributed-extent",
                        extentType: .control,
                        borderModel: .approximateLine,
                        borderConfidence: .unknown,
                        polygons: polygons
                    )
                ]
            )
        ]
    }
}

private extension HistoricalCountry {
    init(snapshot: HistoricalCountrySnapshot) {
        self.init(
            id: snapshot.id,
            displayName: snapshot.displayName,
            shortName: snapshot.shortDisplayName,
            sovereignName: nil,
            parentName: nil,
            borderPrecision: snapshot.extents.first?.borderPrecisionRank,
            infoURL: snapshot.sourceReferences.first?.url ?? snapshot.extents.first?.sourceReferences.first?.url,
            polygons: snapshot.extents.flatMap(\.polygons)
        )
    }
}

private extension HistoricalExtent {
    static func defaultBorderModel(for borderPrecision: Int?) -> HistoricalBorderModel {
        switch borderPrecision {
        case let value? where value >= 3:
            return .preciseLine
        case 2:
            return .lineWithUncertainty
        default:
            return .approximateLine
        }
    }

    static func defaultBorderConfidence(for borderPrecision: Int?) -> HistoricalConfidence {
        switch borderPrecision {
        case let value? where value >= 3:
            return .high
        case 2:
            return .medium
        case 1:
            return .low
        default:
            return .unknown
        }
    }
}

private extension HistoricalSourceReference {
    static func defaultReferences(for url: URL?) -> [HistoricalSourceReference] {
        guard let url else { return [] }
        return [
            HistoricalSourceReference(
                id: url.absoluteString,
                title: "Imported Historical Data",
                url: url
            )
        ]
    }
}

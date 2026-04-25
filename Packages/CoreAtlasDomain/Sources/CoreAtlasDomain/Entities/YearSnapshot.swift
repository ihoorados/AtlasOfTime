import Foundation

public struct YearSnapshot: Sendable {
    public let year: Int
    public let snapshots: [HistoricalCountrySnapshot]

    @available(*, deprecated, message: "Use snapshots instead of legacy countries compatibility projection.")
    public var countries: [HistoricalCountry] {
        snapshots.map(HistoricalCountry.init(snapshot:))
    }

    public var polygons: [GeoPolygon] {
        snapshots.flatMap { snapshot in
            snapshot.extents.flatMap(\.polygons)
        }
    }

    public init(year: Int, snapshots: [HistoricalCountrySnapshot]) {
        self.year = year
        self.snapshots = snapshots
    }

    @available(*, deprecated, message: "Initialize YearSnapshot with snapshots instead of legacy countries.")
    public init(year: Int, countries: [HistoricalCountry]) {
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
                relationships: [],
                sourceReferences: HistoricalSourceReference.defaultReferences(for: country.infoURL)
            )
        }
    }

    public init(year: Int, polygons: [GeoPolygon]) {
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
                ],
                relationships: []
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

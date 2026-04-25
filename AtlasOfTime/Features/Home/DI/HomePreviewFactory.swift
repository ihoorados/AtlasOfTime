import CoreAtlasMap
import Foundation
import CoreAtlasDomain

@MainActor
enum HomePreviewFactory {
    static func makeViewModel() -> AtlasViewModel {
        makeFeatureContainer().makeAtlasViewModel()
    }

    static func makeFeatureContainer() -> AtlasFeatureDIContainer {
        makeFeatureContainerInternal()
    }

    static func makeMapViewFactory() -> any AtlasMapViewFactory {
        AppDIContainer(mapProvider: .mapKit).makeMapViewFactory()
    }

    static func makeDestinationFactory() -> AppDestinationFactory {
        AppDestinationFactory(countryDetailFeatureContainer: CountryDetailPreviewFactory.makeFeatureContainer())
    }

    private static func makeFeatureContainerInternal() -> AtlasFeatureDIContainer {
        let year1900 = 1900
        let year1914 = 1914

        let index = YearIndex(
            minYear: year1900,
            maxYear: year1914,
            availableYears: [year1900, year1914],
            filesByYear: [
                year1900: "preview/1900.geojson.gz",
                year1914: "preview/1914.geojson.gz"
            ]
        )

        let samplePolygon = GeoPolygon(
            outer: [
                Coordinate(lat: 35, lon: -10),
                Coordinate(lat: 55, lon: -10),
                Coordinate(lat: 55, lon: 20),
                Coordinate(lat: 35, lon: 20),
                Coordinate(lat: 35, lon: -10)
            ],
            holes: []
        )

        let snapshots: [Int: YearSnapshot] = [
            year1900: YearSnapshot(year: year1900, polygons: [samplePolygon]),
            year1914: YearSnapshot(year: year1914, polygons: [samplePolygon])
        ]

        let domainContainer = DomainDIContainer(
            yearIndexRepository: PreviewYearIndexRepository(index: index),
            borderRepository: PreviewBorderRepository(snapshots: snapshots)
        )

        return AtlasFeatureDIContainer(
            loadYearIndex: domainContainer.makeLoadYearIndex(),
            loadBordersForYear: domainContainer.makeLoadBordersForYear(),
            debounceNanoseconds: 50_000_000
        )
    }
}

private actor PreviewYearIndexRepository: YearIndexRepository {
    private let index: YearIndex

    init(index: YearIndex) {
        self.index = index
    }

    func load() async throws -> YearIndex {
        index
    }
}

private actor PreviewBorderRepository: BorderRepository {
    private let snapshots: [Int: YearSnapshot]

    init(snapshots: [Int: YearSnapshot]) {
        self.snapshots = snapshots
    }

    func snapshot(for year: Int) async throws -> YearSnapshot {
        guard let snapshot = snapshots[year] else {
            throw AtlasDomainError.yearUnavailable(year)
        }
        return snapshot
    }
}

import CoreAtlasMap
import CoreAtlasMapMapKit
import Foundation
import CoreAtlasDomain

// App composition root container. Keeps assembly logic out of App entry file.
@MainActor
final class AppDIContainer {
    private let mapProvider: MapProvider
    private let dataContainer: DataDIContainer
    private let domainContainer: DomainDIContainer
    private let atlasFeatureContainer: AtlasFeatureDIContainer
    private let countryDetailFeatureContainer: CountryDetailFeatureDIContainer
    private let destinationFactory: AppDestinationFactory

    init(mapProvider: MapProvider = .mapKit) {
        self.mapProvider = mapProvider

        let dataContainer = Self.makeDataContainer()
        self.dataContainer = dataContainer

        let domainContainer = Self.makeDomainContainer(dataContainer: dataContainer)
        self.domainContainer = domainContainer

        let generateCountrySummary = Self.makeGenerateCountrySummary()

        let atlasFeatureContainer = Self.makeAtlasFeatureContainer(domainContainer: domainContainer)
        self.atlasFeatureContainer = atlasFeatureContainer

        let countryDetailFeatureContainer = Self.makeCountryDetailFeatureContainer(
            generateCountrySummary: generateCountrySummary
        )
        self.countryDetailFeatureContainer = countryDetailFeatureContainer
        self.destinationFactory = AppDestinationFactory(
            countryDetailFeatureContainer: countryDetailFeatureContainer
        )
    }

    func makeAtlasViewModel() -> AtlasViewModel {
        atlasFeatureContainer.makeAtlasViewModel()
    }

    func makeAtlasFeatureContainer() -> AtlasFeatureDIContainer {
        atlasFeatureContainer
    }

    func makeCountryDetailFeatureContainer() -> CountryDetailFeatureDIContainer {
        countryDetailFeatureContainer
    }

    func makeDestinationFactory() -> AppDestinationFactory {
        destinationFactory
    }

    func makeMapViewFactory() -> any AtlasMapViewFactory {
        switch mapProvider {
        case .mapKit:
            MapKitAtlasMapViewFactory()
        }
    }

    // Extension points for additional features follow the same pattern.
    private static func makeDataContainer() -> DataDIContainer {
        DataDIContainer()
    }

    private static func makeDomainContainer(dataContainer: DataDIContainer) -> DomainDIContainer {
        DomainDIContainer(
            yearIndexRepository: dataContainer.makeYearIndexRepository(),
            borderRepository: dataContainer.makeBorderRepository()
        )
    }

    private static func makeAtlasFeatureContainer(domainContainer: DomainDIContainer) -> AtlasFeatureDIContainer {
        AtlasFeatureDIContainer(
            loadYearIndex: domainContainer.makeLoadYearIndex(),
            loadBordersForYear: domainContainer.makeLoadBordersForYear()
        )
    }

    private static func makeCountryDetailFeatureContainer(
        generateCountrySummary: GenerateCountrySummary
    ) -> CountryDetailFeatureDIContainer {
        CountryDetailFeatureDIContainer(generateCountrySummary: generateCountrySummary)
    }

    private static func makeGenerateCountrySummary() -> GenerateCountrySummary {
        GenerateCountrySummary(
            generator: FoundationModelCountrySummaryGenerator()
        )
    }
}

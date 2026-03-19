import Foundation

// App composition root container. Keeps assembly logic out of App entry file.
@MainActor
final class AppDIContainer {
    private let dataContainer: DataDIContainer
    private let domainContainer: DomainDIContainer
    private let atlasFeatureContainer: AtlasFeatureDIContainer
    private let destinationFactory: AppDestinationFactory

    init() {
        let dataContainer = Self.makeDataContainer()
        self.dataContainer = dataContainer

        let domainContainer = Self.makeDomainContainer(dataContainer: dataContainer)
        self.domainContainer = domainContainer

        let atlasFeatureContainer = Self.makeAtlasFeatureContainer(domainContainer: domainContainer)
        self.atlasFeatureContainer = atlasFeatureContainer
        self.destinationFactory = AppDestinationFactory(atlasFeatureContainer: atlasFeatureContainer)
    }

    func makeAtlasViewModel() -> AtlasViewModel {
        atlasFeatureContainer.makeAtlasViewModel()
    }

    func makeDestinationFactory() -> AppDestinationFactory {
        destinationFactory
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
            loadBordersForYear: domainContainer.makeLoadBordersForYear(),
            generateCountrySummary: GenerateCountrySummary(
                generator: FoundationModelCountrySummaryGenerator()
            )
        )
    }
}

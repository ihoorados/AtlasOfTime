import CoreAtlasMap
import Foundation
import CoreAtlasDomain
import SwiftUI

#if canImport(CoreAtlasAI)
import struct CoreAtlasAI.FoundationModelCountrySummaryGenerator
#endif

#if canImport(CoreAtlasMapMapKit)
import CoreAtlasMapMapKit
#endif

// App composition root container. Keeps assembly logic out of App entry file.
@MainActor
final class AppDIContainer {
    private let mapProvider: MapProvider
    private let atlasFeatureContainer: AtlasFeatureDIContainer
    private let countryDetailFeatureContainer: CountryDetailFeatureDIContainer
    private let destinationFactory: AppDestinationFactory

    init(mapProvider: MapProvider = .mapKit) {
        self.mapProvider = mapProvider

        let dataContainer = Self.makeDataContainer()
        let domainContainer = Self.makeDomainContainer(dataContainer: dataContainer)
        let generateCountrySummary = domainContainer.makeGenerateCountrySummary(
            generator: Self.makeCountrySummaryGenerator()
        )

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

    func makeRootDependencies() -> AppRootDependencies {
        AppRootDependencies(
            atlasFeatureContainer: atlasFeatureContainer,
            mapViewFactory: makeMapViewFactory(),
            destinationFactory: destinationFactory
        )
    }

    func makeMapViewFactory() -> any AtlasMapViewFactory {
        switch mapProvider {
        case .mapKit:
            #if canImport(CoreAtlasMapMapKit) && (os(iOS) || os(macOS))
            MapKitAtlasMapViewFactory()
            #else
            UnsupportedAtlasMapViewFactory()
            #endif
        }
    }

    // Extension points for additional features follow the same pattern.
    private static func makeDataContainer() -> DataDIContainer {
        DataDIContainer()
    }

    private static func makeDomainContainer(dataContainer: DataDIContainer) -> DomainDIContainer {
        DomainDIContainer(
            yearIndexRepository: dataContainer.makeYearIndexRepository(),
            borderRepository: dataContainer.makeBorderRepository(),
            poiRepository: dataContainer.makePOIRepository()
        )
    }

    private static func makeAtlasFeatureContainer(domainContainer: DomainDIContainer) -> AtlasFeatureDIContainer {
        AtlasFeatureDIContainer(
            loadYearIndex: domainContainer.makeLoadYearIndex(),
            loadBordersForYear: domainContainer.makeLoadBordersForYear(),
            loadPOIsForYear: domainContainer.makeLoadPOIsForYear()
        )
    }

    private static func makeCountryDetailFeatureContainer(
        generateCountrySummary: GenerateCountrySummary
    ) -> CountryDetailFeatureDIContainer {
        CountryDetailFeatureDIContainer(generateCountrySummary: generateCountrySummary)
    }

    private static func makeCountrySummaryGenerator() -> any CountrySummaryGenerating {
        #if canImport(CoreAtlasAI) && (os(iOS) || os(macOS))
        FoundationModelCountrySummaryGenerator()
        #else
        UnsupportedCountrySummaryGenerator()
        #endif
    }
}

private struct UnsupportedCountrySummaryGenerator: CountrySummaryGenerating {
    func generateSummary(for request: CountrySummaryRequest) async throws -> CountrySummaryResult {
        CountrySummaryResult(
            title: "\(request.displayName) — \(request.year)",
            overview: "Country summary generation is not available on this platform.",
            confidenceNote: "The local dataset is available, but the summary generator is not supported here."
        )
    }
}

@MainActor
private struct UnsupportedAtlasMapViewFactory: AtlasMapViewFactory {
    func makeMapView(
        state: AtlasMapViewState,
        onSelectionChanged: @escaping @MainActor @Sendable (String?) -> Void,
        onPointAnnotationSelectionChanged: @escaping @MainActor @Sendable (String?) -> Void
    ) -> AnyView {
        AnyView(
            Text("Map rendering is not available on this platform.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        )
    }
}

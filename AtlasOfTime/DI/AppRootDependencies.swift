import CoreAtlasMap

@MainActor
struct AppRootDependencies {
    let atlasFeatureContainer: AtlasFeatureDIContainer
    let mapViewFactory: any AtlasMapViewFactory
    let destinationFactory: AppDestinationFactory
}

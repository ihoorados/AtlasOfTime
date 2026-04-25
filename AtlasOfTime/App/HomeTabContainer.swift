import CoreAtlasMap
import SwiftUI

struct HomeTabContainer: View {
    @ObservedObject private var navigationStore: AppNavigationStore
    @StateObject private var viewModel: AtlasViewModel
    private let mapViewFactory: any AtlasMapViewFactory
    private let destinationFactory: AppDestinationFactory

    init(
        navigationStore: AppNavigationStore,
        atlasFeatureContainer: AtlasFeatureDIContainer,
        mapViewFactory: any AtlasMapViewFactory,
        destinationFactory: AppDestinationFactory
    ) {
        self.navigationStore = navigationStore
        self.destinationFactory = destinationFactory
        self.mapViewFactory = mapViewFactory
        _viewModel = StateObject(
            wrappedValue: atlasFeatureContainer.makeAtlasViewModel()
        )
    }

    var body: some View {
        NavigationStack(path: $navigationStore.homeNavigation.path) {
            HomeScene(
                viewModel: viewModel,
                mapViewFactory: mapViewFactory,
                onSelectedCountryTapped: { snapshot in
                    navigationStore.push(.countryDetail(.init(snapshot: snapshot)))
                }
            )
            .navigationDestination(for: HomeRoute.self) { route in
                destinationFactory.makeHomeDestination(for: route)
            }
        }
    }
}

#if DEBUG
struct HomeTabContainer_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        HomeTabContainer(
            navigationStore: AppNavigationStore(),
            atlasFeatureContainer: HomePreviewFactory.makeFeatureContainer(),
            mapViewFactory: HomePreviewFactory.makeMapViewFactory(),
            destinationFactory: HomePreviewFactory.makeDestinationFactory()
        )
    }
}
#endif

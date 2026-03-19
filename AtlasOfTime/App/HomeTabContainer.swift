import SwiftUI

struct HomeTabContainer: View {
    @ObservedObject var navigationStore: AppNavigationStore
    @StateObject private var viewModel: AtlasViewModel
    let destinationFactory: AppDestinationFactory
    let routeResolver: HomeRouteResolver

    init(
        navigationStore: AppNavigationStore,
        atlasFeatureContainer: AtlasFeatureDIContainer,
        destinationFactory: AppDestinationFactory,
        routeResolver: HomeRouteResolver = HomeRouteResolver()
    ) {
        self.navigationStore = navigationStore
        self.destinationFactory = destinationFactory
        self.routeResolver = routeResolver
        _viewModel = StateObject(
            wrappedValue: atlasFeatureContainer.makeAtlasViewModel()
        )
    }

    var body: some View {
        NavigationStack(path: $navigationStore.homeNavigation.path) {
            HomeScene(
                viewModel: viewModel,
                onSelectedCountryTapped: { snapshot in
                    navigationStore.push(.countryDetail(countryID: snapshot.id))
                }
            )
            .navigationDestination(for: HomeRoute.self) { route in
                if let snapshot = routeResolver.snapshot(
                    for: route,
                    visibleSnapshots: viewModel.visibleSnapshots
                ) {
                    destinationFactory.makeCountryDetailScene(snapshot: snapshot)
                } else {
                    missingCountryDetailScene
                }
            }
        }
    }

    private var missingCountryDetailScene: some View {
        ContentUnavailableView(
            String(localized: AppStrings.Common.unavailableValue),
            systemImage: "exclamationmark.triangle",
            description: Text(String(localized: AppStrings.Home.Detail.emptyMessage))
        )
    }
}

#if DEBUG
struct HomeTabContainer_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        HomeTabContainer(
            navigationStore: AppNavigationStore(),
            atlasFeatureContainer: HomePreviewFactory.makeFeatureContainer(),
            destinationFactory: HomePreviewFactory.makeDestinationFactory()
        )
    }
}
#endif

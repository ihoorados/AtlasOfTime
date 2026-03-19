import SwiftUI

struct HomeTabContainer: View {
    @ObservedObject var navigationStore: AppNavigationStore
    @StateObject private var viewModel: AtlasViewModel
    let destinationFactory: AppDestinationFactory

    init(
        navigationStore: AppNavigationStore,
        atlasFeatureContainer: AtlasFeatureDIContainer,
        destinationFactory: AppDestinationFactory
    ) {
        self.navigationStore = navigationStore
        self.destinationFactory = destinationFactory
        _viewModel = StateObject(
            wrappedValue: atlasFeatureContainer.makeAtlasViewModel()
        )
    }

    var body: some View {
        NavigationStack(path: $navigationStore.homeNavigation.path) {
            HomeScene(
                viewModel: viewModel,
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
            destinationFactory: HomePreviewFactory.makeDestinationFactory()
        )
    }
}
#endif

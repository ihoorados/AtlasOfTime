import SwiftUI

struct HomeTabContainer: View {
    @ObservedObject var navigationStore: AppNavigationStore
    @ObservedObject var viewModel: AtlasViewModel
    let makeCountryDetailScene: (HistoricalCountrySnapshot) -> CountryDetailScene

    var body: some View {
        NavigationStack(path: $navigationStore.homePath) {
            HomeScene(
                viewModel: viewModel,
                onSelectedCountryTapped: { snapshot in
                    navigationStore.push(.countryDetail(countryID: snapshot.id))
                }
            )
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case let .countryDetail(countryID):
                    if let snapshot = resolvedSnapshot(for: countryID) {
                        makeCountryDetailScene(snapshot)
                    } else {
                        missingCountryDetailScene
                    }
                }
            }
        }
    }

    private func resolvedSnapshot(for countryID: String) -> HistoricalCountrySnapshot? {
        viewModel.visibleSnapshots.first { $0.id == countryID }
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
            viewModel: HomePreviewFactory.makeViewModel(),
            makeCountryDetailScene: HomePreviewFactory.makeCountryDetailScene(snapshot:)
        )
    }
}
#endif

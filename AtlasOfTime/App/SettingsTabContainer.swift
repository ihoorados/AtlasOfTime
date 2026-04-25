import SwiftUI

struct SettingsTabContainer: View {
    @ObservedObject private var navigationStore: AppNavigationStore
    @ObservedObject private var appearanceController: AppearanceController
    @ObservedObject private var languageController: AppLanguageController
    @ObservedObject private var preferencesController: MapPreferencesController
    private let destinationFactory: AppDestinationFactory

    init(
        navigationStore: AppNavigationStore,
        appearanceController: AppearanceController,
        languageController: AppLanguageController,
        preferencesController: MapPreferencesController,
        destinationFactory: AppDestinationFactory
    ) {
        self.navigationStore = navigationStore
        self.appearanceController = appearanceController
        self.languageController = languageController
        self.preferencesController = preferencesController
        self.destinationFactory = destinationFactory
    }

    var body: some View {
        NavigationStack(path: $navigationStore.settingsNavigation.path) {
            SettingsScene(
                onRouteSelected: { route in
                    navigationStore.push(route)
                }
            )
            .navigationDestination(for: SettingsRoute.self) { route in
                destinationFactory.makeSettingsDestination(
                    for: route,
                    appearanceController: appearanceController,
                    languageController: languageController,
                    preferencesController: preferencesController
                )
            }
        }
    }
}

#if DEBUG
struct SettingsTabContainer_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        SettingsTabContainer(
            navigationStore: AppNavigationStore(),
            appearanceController: SettingsPreviewFactory.makeAppearanceController(),
            languageController: SettingsPreviewFactory.makeLanguageController(),
            preferencesController: SettingsPreviewFactory.makePreferencesController(),
            destinationFactory: HomePreviewFactory.makeDestinationFactory()
        )
    }
}
#endif

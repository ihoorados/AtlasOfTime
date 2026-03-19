import SwiftUI

struct SettingsTabContainer: View {
    @ObservedObject var navigationStore: AppNavigationStore
    @ObservedObject var appearanceController: AppearanceController
    @ObservedObject var languageController: AppLanguageController
    @ObservedObject var preferencesController: AppPreferencesController

    var body: some View {
        NavigationStack(path: $navigationStore.settingsNavigation.path) {
            SettingsScene(
                onRouteSelected: { route in
                    navigationStore.push(route)
                }
            )
            .navigationDestination(for: SettingsRoute.self) { route in
                switch route {
                case .appearance:
                    AppearanceSettingsScene(
                        appearanceController: appearanceController,
                        languageController: languageController
                    )
                case .map:
                    MapSettingsScene(preferencesController: preferencesController)
                case .data:
                    DataSettingsScene()
                }
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
            preferencesController: SettingsPreviewFactory.makePreferencesController()
        )
    }
}
#endif

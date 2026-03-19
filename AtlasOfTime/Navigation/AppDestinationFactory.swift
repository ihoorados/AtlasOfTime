import SwiftUI

@MainActor
final class AppDestinationFactory {
    private let atlasFeatureContainer: AtlasFeatureDIContainer

    init(atlasFeatureContainer: AtlasFeatureDIContainer) {
        self.atlasFeatureContainer = atlasFeatureContainer
    }

    func makeCountryDetailScene(
        snapshot: HistoricalCountrySnapshot
    ) -> CountryDetailScene {
        atlasFeatureContainer.makeCountryDetailScene(snapshot: snapshot)
    }

    @ViewBuilder
    func makeHomeDestination(for route: HomeRoute) -> some View {
        switch route {
        case .countryDetail(let context):
            makeCountryDetailScene(snapshot: context.snapshot)
        }
    }

    @ViewBuilder
    func makeSettingsDestination(
        for route: SettingsRoute,
        appearanceController: AppearanceController,
        languageController: AppLanguageController,
        preferencesController: AppPreferencesController
    ) -> some View {
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

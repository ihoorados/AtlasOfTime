import SwiftUI

struct RootTabScreen: View {
    @ObservedObject var navigationStore: AppNavigationStore
    let atlasFeatureContainer: AtlasFeatureDIContainer
    @ObservedObject var appearanceController: AppearanceController
    @ObservedObject var languageController: AppLanguageController
    @ObservedObject var preferencesController: AppPreferencesController
    let destinationFactory: AppDestinationFactory
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        TabView(selection: $navigationStore.selectedTab) {
            Tab(AppStrings.Tabs.home, systemImage: "house", value: AppTab.home) {
                HomeTabContainer(
                    navigationStore: navigationStore,
                    atlasFeatureContainer: atlasFeatureContainer,
                    destinationFactory: destinationFactory
                )
            }

            Tab(AppStrings.Tabs.settings, systemImage: "gearshape", value: AppTab.settings) {
                SettingsTabContainer(
                    navigationStore: navigationStore,
                    appearanceController: appearanceController,
                    languageController: languageController,
                    preferencesController: preferencesController
                )
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .environment(
            \.atlasTheme,
            AtlasTheme.resolve(
                colorScheme: colorScheme,
                glassEnabled: appearanceController.glassEnabled
            )
        )
    }
}

#if DEBUG
struct RootTabScreen_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        Group {
            rootPreview(localeIdentifier: "en", layoutDirection: .leftToRight)
                .previewDisplayName(PreviewDisplayName.english("Root Tabs"))

            rootPreview(localeIdentifier: "fa", layoutDirection: .rightToLeft)
                .previewDisplayName(PreviewDisplayName.persianRTL("Root Tabs"))
        }
    }

    @MainActor
    private static func rootPreview(
        localeIdentifier: String,
        layoutDirection: LayoutDirection
    ) -> some View {
        RootTabScreen(
            navigationStore: AppNavigationStore(),
            atlasFeatureContainer: HomePreviewFactory.makeFeatureContainer(),
            appearanceController: SettingsPreviewFactory.makeAppearanceController(),
            languageController: SettingsPreviewFactory.makeLanguageController(),
            preferencesController: SettingsPreviewFactory.makePreferencesController(),
            destinationFactory: HomePreviewFactory.makeDestinationFactory()
        )
        .environment(\.locale, Locale(identifier: localeIdentifier))
        .environment(\.layoutDirection, layoutDirection)
    }
}
#endif

import CoreAtlasMap
import SwiftUI

struct RootTabScreen: View {
    @ObservedObject private var navigationStore: AppNavigationStore
    private let atlasFeatureContainer: AtlasFeatureDIContainer
    private let mapViewFactory: any AtlasMapViewFactory
    @ObservedObject private var appearanceController: AppearanceController
    @ObservedObject private var languageController: AppLanguageController
    @ObservedObject private var preferencesController: MapPreferencesController
    private let destinationFactory: AppDestinationFactory
    @Environment(\.colorScheme) private var colorScheme

    init(
        navigationStore: AppNavigationStore,
        atlasFeatureContainer: AtlasFeatureDIContainer,
        mapViewFactory: any AtlasMapViewFactory,
        appearanceController: AppearanceController,
        languageController: AppLanguageController,
        preferencesController: MapPreferencesController,
        destinationFactory: AppDestinationFactory
    ) {
        self.navigationStore = navigationStore
        self.atlasFeatureContainer = atlasFeatureContainer
        self.mapViewFactory = mapViewFactory
        self.appearanceController = appearanceController
        self.languageController = languageController
        self.preferencesController = preferencesController
        self.destinationFactory = destinationFactory
    }

    var body: some View {
        TabView(selection: $navigationStore.selectedTab) {
            Tab(AppStrings.Tabs.home, systemImage: "house", value: AppTab.home) {
                HomeTabContainer(
                    navigationStore: navigationStore,
                    atlasFeatureContainer: atlasFeatureContainer,
                    mapViewFactory: mapViewFactory,
                    destinationFactory: destinationFactory
                )
            }

            Tab(AppStrings.Tabs.settings, systemImage: "gearshape", value: AppTab.settings) {
                SettingsTabContainer(
                    navigationStore: navigationStore,
                    appearanceController: appearanceController,
                    languageController: languageController,
                    preferencesController: preferencesController,
                    destinationFactory: destinationFactory
                )
            }
        }
        .atlasTabBarMinimizeOnScrollDown()
        .environment(
            \.atlasTheme,
            AtlasTheme.resolve(
                colorScheme: colorScheme,
                glassEnabled: appearanceController.glassEnabled
            )
        )
    }
}

private extension View {
    @ViewBuilder
    func atlasTabBarMinimizeOnScrollDown() -> some View {
        #if os(iOS)
        tabBarMinimizeBehavior(.onScrollDown)
        #else
        self
        #endif
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
            mapViewFactory: HomePreviewFactory.makeMapViewFactory(),
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

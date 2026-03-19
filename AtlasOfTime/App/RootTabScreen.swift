import SwiftUI

struct RootTabScreen: View {
    @ObservedObject var navigationStore: AppNavigationStore
    @ObservedObject var viewModel: AtlasViewModel
    @ObservedObject var appearanceController: AppearanceController
    @ObservedObject var languageController: AppLanguageController
    @ObservedObject var preferencesController: AppPreferencesController
    let makeCountryDetailScene: (HistoricalCountrySnapshot) -> CountryDetailScene
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        TabView(selection: $navigationStore.selectedTab) {
            Tab(AppStrings.Tabs.home, systemImage: "house", value: AppTab.home) {
                HomeTabContainer(
                    navigationStore: navigationStore,
                    viewModel: viewModel,
                    makeCountryDetailScene: makeCountryDetailScene
                )
            }

            Tab(AppStrings.Tabs.settings, systemImage: "gearshape", value: AppTab.settings) {
                SettingsScene(
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
            viewModel: HomePreviewFactory.makeViewModel(),
            appearanceController: SettingsPreviewFactory.makeAppearanceController(),
            languageController: SettingsPreviewFactory.makeLanguageController(),
            preferencesController: SettingsPreviewFactory.makePreferencesController(),
            makeCountryDetailScene: HomePreviewFactory.makeCountryDetailScene(snapshot:)
        )
        .environment(\.locale, Locale(identifier: localeIdentifier))
        .environment(\.layoutDirection, layoutDirection)
    }
}
#endif

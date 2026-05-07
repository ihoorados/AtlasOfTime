import CoreAtlasAppSettings
import CoreAtlasMap
import SwiftUI

@main
struct AtlasOfTimeApp: App {
    private let rootDependencies: AppRootDependencies
    @StateObject private var navigationStore = AppNavigationStore()
    @StateObject private var appearanceController = AppearanceController()
    @StateObject private var languageController = AppLanguageController()
    @StateObject private var preferencesController = MapPreferencesController()

    init() {
        let appContainer = AppDIContainer()
        self.rootDependencies = appContainer.makeRootDependencies()
    }

    var body: some Scene {
        #if os(macOS)
        WindowGroup {
            appWindowContent
        }
        .defaultSize(width: 1180, height: 760)
        #else
        WindowGroup {
            appWindowContent
        }
        #endif
    }

    private var appWindowContent: some View {
        Group {
            if let localeIdentifier = languageController.selectedLanguage.localeIdentifier,
               let isRightToLeft = languageController.selectedLanguage.isRightToLeft {
                rootContent
                    .environment(\.locale, Locale(identifier: localeIdentifier))
                    .environment(\.layoutDirection, isRightToLeft ? .rightToLeft : .leftToRight)
            } else {
                rootContent
            }
        }
    }

    private var rootContent: some View {
        RootTabScreen(
            navigationStore: navigationStore,
            atlasFeatureContainer: rootDependencies.atlasFeatureContainer,
            mapViewFactory: rootDependencies.mapViewFactory,
            appearanceController: appearanceController,
            languageController: languageController,
            preferencesController: preferencesController,
            destinationFactory: rootDependencies.destinationFactory
        )
        .preferredColorScheme(appearanceController.preferredColorScheme)
        .environment(\.atlasAppearance, appearanceController.selectedAppearance)
        .environment(\.atlasGlassEnabled, appearanceController.glassEnabled)
        .environment(\.atlasShowYearRangeLabels, preferencesController.showYearRangeLabels)
        .environment(\.atlasShowLoadingIndicator, preferencesController.showLoadingIndicator)
    }
}

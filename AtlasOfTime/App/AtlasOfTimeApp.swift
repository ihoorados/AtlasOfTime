import SwiftUI

@main
struct AtlasOfTimeApp: App {
    private let appContainer: AppDIContainer
    private let destinationFactory: AppDestinationFactory
    @StateObject private var navigationStore = AppNavigationStore()
    @StateObject private var viewModel: AtlasViewModel
    @StateObject private var appearanceController = AppearanceController()
    @StateObject private var languageController = AppLanguageController()
    @StateObject private var preferencesController = AppPreferencesController()

    init() {
        let appContainer = AppDIContainer()
        self.appContainer = appContainer
        self.destinationFactory = appContainer.makeDestinationFactory()
        _viewModel = StateObject(
            wrappedValue: appContainer.makeAtlasViewModel()
        )
    }

    var body: some Scene {
        WindowGroup {
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
    }

    private var rootContent: some View {
        RootTabScreen(
            navigationStore: navigationStore,
            viewModel: viewModel,
            appearanceController: appearanceController,
            languageController: languageController,
            preferencesController: preferencesController,
            destinationFactory: destinationFactory
        )
        .preferredColorScheme(appearanceController.preferredColorScheme)
        .environment(\.atlasAppearance, appearanceController.selectedAppearance)
        .environment(\.atlasGlassEnabled, appearanceController.glassEnabled)
        .environment(\.atlasShowYearRangeLabels, preferencesController.showYearRangeLabels)
        .environment(\.atlasShowLoadingIndicator, preferencesController.showLoadingIndicator)
    }
}

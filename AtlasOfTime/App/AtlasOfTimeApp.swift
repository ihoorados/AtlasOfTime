import SwiftUI

@main
struct AtlasOfTimeApp: App {
    private let appContainer: AppDIContainer
    @StateObject private var viewModel: AtlasViewModel
    @StateObject private var appearanceController = AppearanceController()
    @StateObject private var languageController = AppLanguageController()
    @StateObject private var preferencesController = AppPreferencesController()

    init() {
        let appContainer = AppDIContainer()
        self.appContainer = appContainer
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
            viewModel: viewModel,
            appearanceController: appearanceController,
            languageController: languageController,
            preferencesController: preferencesController,
            makeCountryDetailScene: appContainer.makeCountryDetailScene(snapshot:)
        )
        .preferredColorScheme(appearanceController.preferredColorScheme)
        .environment(\.atlasAppearance, appearanceController.selectedAppearance)
        .environment(\.atlasGlassEnabled, appearanceController.glassEnabled)
        .environment(\.atlasShowYearRangeLabels, preferencesController.showYearRangeLabels)
        .environment(\.atlasShowLoadingIndicator, preferencesController.showLoadingIndicator)
    }
}

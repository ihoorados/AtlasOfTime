import SwiftUI

@main
struct AtlasOfTimeApp: App {
    private let appContainer: AppDIContainer
    @StateObject private var viewModel: AtlasViewModel
    @StateObject private var appearanceController = AppearanceController()

    init() {
        let appContainer = AppDIContainer()
        self.appContainer = appContainer
        _viewModel = StateObject(
            wrappedValue: appContainer.makeAtlasViewModel()
        )
    }

    var body: some Scene {
        WindowGroup {
            RootTabScreen(
                viewModel: viewModel,
                appearanceController: appearanceController
            )
            .preferredColorScheme(appearanceController.preferredColorScheme)
            .environment(\.atlasAppearance, appearanceController.selectedAppearance)
            .environment(\.atlasGlassEnabled, appearanceController.glassEnabled)
        }
    }
}

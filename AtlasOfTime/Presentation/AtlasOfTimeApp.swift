import SwiftUI

@main
struct AtlasOfTimeApp: App {
    private let appContainer: AppDIContainer
    @StateObject private var viewModel: AtlasViewModel

    init() {
        let appContainer = AppDIContainer()
        self.appContainer = appContainer
        _viewModel = StateObject(
            wrappedValue: appContainer.makeAtlasViewModel()
        )
    }

    var body: some Scene {
        WindowGroup {
            RootTabScreen(viewModel: viewModel)
        }
    }
}

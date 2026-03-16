import SwiftUI

struct RootTabScreen: View {
    @ObservedObject var viewModel: AtlasViewModel
    @ObservedObject var appearanceController: AppearanceController
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeScene(viewModel: viewModel)
            }

            Tab("Settings", systemImage: "gearshape") {
                SettingsScene(appearanceController: appearanceController)
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
        RootTabScreen(
            viewModel: PreviewAppDIContainer().makeAtlasViewModel(),
            appearanceController: AppearanceController()
        )
    }
}
#endif

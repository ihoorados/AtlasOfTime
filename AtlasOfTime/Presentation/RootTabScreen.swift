import SwiftUI

struct RootTabScreen: View {
    @ObservedObject var viewModel: AtlasViewModel

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeScene(viewModel: viewModel)
            }

            Tab("Settings", systemImage: "gearshape") {
                SettingsScene()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

#if DEBUG
struct RootTabScreen_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        RootTabScreen(viewModel: PreviewAppDIContainer().makeAtlasViewModel())
    }
}
#endif

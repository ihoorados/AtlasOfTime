import SwiftUI

struct RootTabScreen: View {
    @ObservedObject var viewModel: AtlasViewModel

    var body: some View {
        TabView {
            HomeScene(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            SettingsPlaceholderScreen()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

private struct SettingsPlaceholderScreen: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Image(systemName: "gearshape")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(.secondary)

                Text("Settings")
                    .font(.title2.weight(.semibold))

                Text("Settings scene will be added in the next step.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(24)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Settings")
        }
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

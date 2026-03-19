import Combine
import Foundation

@MainActor
final class AppNavigationStore: ObservableObject {
    @Published var selectedTab: AppTab
    @Published var homePath: [HomeRoute]
    @Published var settingsPath: [SettingsRoute]

    init(
        selectedTab: AppTab = .home,
        homePath: [HomeRoute] = [],
        settingsPath: [SettingsRoute] = []
    ) {
        self.selectedTab = selectedTab
        self.homePath = homePath
        self.settingsPath = settingsPath
    }

    func push(_ route: HomeRoute) {
        selectedTab = .home
        homePath.append(route)
    }

    func push(_ route: SettingsRoute) {
        selectedTab = .settings
        settingsPath.append(route)
    }

    func popHome() {
        guard !homePath.isEmpty else { return }
        homePath.removeLast()
    }

    func popSettings() {
        guard !settingsPath.isEmpty else { return }
        settingsPath.removeLast()
    }

    func popToHomeRoot() {
        homePath.removeAll()
    }

    func popToSettingsRoot() {
        settingsPath.removeAll()
    }

    func reset() {
        selectedTab = .home
        homePath.removeAll()
        settingsPath.removeAll()
    }
}
